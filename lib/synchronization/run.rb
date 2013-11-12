module Synchronization
  # @author Andrew Emelianenko
  class Run
    include ActionView::Helpers

    # Start synchronization for user
    #
    # @param user [User]
    def initialize(user)
      @user = user
      @synchronization = UserSynchronization.init(@user.id)

      thread
    end

    def thread
      Thread.new do
        initialize_variables

        load_labels_and_emails
        load_folders_and_files

        @emails.each do |label, emails|
          @current_label = replace_label_name(label)
          process_current_label
          @imap.select(label)

          emails.each do |email_id|
            process_email(email_id)
          end
        end

        deinitialize_variables
        finish_synchronization
      end
    rescue => e
      @synchronization.set_error_status(e.message)
      @logger.error "[ERROR] #{e.message}"

      deinitialize_variables

      Puub.instance.publish("user_#{@user.id}", { event: 'synchronization_update', data: { id: @synchronization.id, action: 'reload_page' } })
    end

    # Return synchronization
    #
    # @return [UserSynchronization]
    def synchronization
      @synchronization
    end

    private

    @user
    @user_api
    @user_filters
    @user_settings

    @synchronization

    @emails
    @files
    @label_folders
    @file_types_folders

    @extensions

    @current_label
    @current_mail
    @current_attachment

    @logger

    # Initialize variables and IMAP connection
    def initialize_variables
      @logger = Logger.new('log/synchronization.log')
      @logger.debug '==================== [SYNCHRONIZATION] ===================='

      @user_api = @user.api
      @user_filters = @user.filters
      @user_settings = @user.settings

      @emails = {}
      @files = {}
      @label_folders = {}
      @file_types_folders = {}

      @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
      @imap.authenticate('XOAUTH2', @user.email, @user_api.tokens[:access_token])

      @extensions = Extension.all_hash

      @logger.debug 'Variables initialized'
    end

    # Load labels and emails
    def load_labels_and_emails
      email_count = 0
      last_sync = @user.synchronizations.finished.last

      if last_sync.nil?
        search_query = 'X-GM-RAW has:attachment'
      else
        time = Time.at(last_sync.started_at)
        search_query = "X-GM-RAW \"has:attachment after:#{time.year}/#{time.month}/0#{time.day}\""
      end

      @imap.list('', '%').to_a.each do |label|
        next unless label.attr.find_index(:Noselect).nil?

        @imap.select(label.name)
        emails = @imap.search(search_query)

        next if emails.empty?

        @emails[label.name] = emails
        email_count += emails.count
      end

      @synchronization.update_attribute(:email_count, email_count)

      @logger.debug 'Labels and mails ids was successful loaded'
    end

    # Load files and folders from Google Drive
    def load_folders_and_files
      # load Attachments.IO folder
      items = @user_api.load_files(title: IO_ROOT_FOLDER, is_root: true).data.items

      # if Attachments.IO not exist, create it!
      if items.empty?
        result = @user_api.create_folder(title: IO_ROOT_FOLDER).data
        @main_folder = { id: result.id, link: result.alternate_link }

        return
      else
        folder = items.first
        @main_folder = { id: folder.id, link: folder.alternate_link }
      end

      # load all folders
      all_folders = @user_api.load_files(is_folder: true).data.items

      # parse label folders
      label_ids = {}
      all_folders.each do |folder|
        if folder.parents[0] && folder.parents[0].id == @main_folder[:id]
          @label_folders[folder.title] = { id: folder.id, link: folder.alternate_link, sub_folders: {} }
          label_ids[folder.id] = folder.title
        end
      end

      # parse file types folders
      unless @label_folders.empty?
        all_folders.each do |folder|
          if folder.parents[0] && label_ids.include?(folder.parents[0].id)
            @label_folders[label_ids[folder.parents[0].id]][:sub_folders][folder.title] = { id: folder.id, link: folder.alternate_link }
            @file_types_folders[folder.id] = label_ids[folder.parents[0].id]
          end
        end
      end

      # load all files & parse it
      all_files = @user_api.load_files(is_folder: false).data.items
      all_files.each do |file|
        if file.parents[0] && @file_types_folders[file.parents[0].id]
          @files[file.title] = { size: file.file_size, link: file.alternate_link, parent_id: file.parents[0].id }
        end
      end

      @logger.debug 'Folders and files was successful processed'
    end

    # Replace label name
    #
    # @param label [String] label name in Google Mail
    # @param folder [String] folder name in Google Drive
    def replace_label_name(label_name)
      case label_name
        when 'INBOX'
          '@ttachments.io'
        else
          label_name
      end
    end

    # Create folder for label, if not exist
    def process_current_label
      if @label_folders[@current_label].nil?
        result = @user_api.create_folder(title: @current_label, parent_id: @main_folder[:id])
        @label_folders[@current_label] = { id: result.data.id, link: result.data.alternate_link, sub_folders: {} }
      end

      @logger.debug "Label #{@current_label} was selected"
    end

    # Load email from Google Mail and process attachments
    #
    # @param email_id [Integer] id of email for current label
    def process_email(email_id)
      @current_mail = Mail.read_from_string(@imap.fetch(email_id, 'RFC822')[0].attr['RFC822'])

      @current_mail.attachments.each do |attachment|
        process_attachment(attachment)
      end

      @synchronization.update_attribute(:email_parsed, @synchronization.email_parsed.to_i + 1)

      Puub.instance.publish("user_#{@user.id}",
                            {
                                event: 'progressbar',
                                data: {
                                    id: @synchronization.id,
                                    action: 'update',
                                    parsed: @synchronization.email_parsed.to_i,
                                    count: @synchronization.email_count.to_i
                                }
                            })

      @logger.debug "Email #{@current_mail.subject} was successful processed"
    end

    # Generate filename, check is uploaded file, check filters and upload file
    #
    # @param attachment [Mail::Part] attachment from Mail
    def process_attachment(attachment)
      @current_attachment = attachment
      filename = generate_filename(@current_attachment)

      @logger.debug "+ Attachment \"#{filename}\" initialized"

      if is_uploaded(filename)
        @logger.debug '- File already uploaded'
        return
      end

      unless check_filters
        @logger.debug '- File not pass a filters'
      end

      upload_file(filename)
    end

    # Generate filename
    #
    # @param attachment [Mail::Part] attachment from Mail
    # @return [String] filename of attachment for Google Drive
    def generate_filename(attachment)
      # TODO: fix filename generation
      filename = Russian.translit(attachment.filename)

      if @user_settings.subject_in_filename && @current_mail.subject
        filename = "#{Russian.translit(@current_mail.subject)} - #{filename}"
      end

      filename
    end

    # Check if file was uploaded already
    #
    # @param filename [String] name of file
    # @return [TrueClass/FalseClass]
    def is_uploaded(filename)
      if !@files[filename].nil? &&
         !@file_types_folders.nil? &&
         @file_types_folders[@files[filename][:parent_id]] == @current_label &&
         (@current_attachment.body.decoded.size == @files[filename][:size])

        return true
      end

      false
    end

    # Check filters for attachment
    #
    # @return [TrueClass/FalseClass] pass or not pass filters
    def check_filters
      ext = File.extname(@current_attachment.filename)

      if Extension.image.include?(ext) && @user_filters.images_filters

        # allowed extensions
        unless @user_filters.images_extensions.include?(ext)
          return false
        end

        # check file size
        if (!@user_filters.images_min_size.nil? && @user_filters.images_min_size.to_i > @current_attachment.body.decoded.size) ||
            (!@user_filters.images_max_size.nil? && @user_filters.images_max_size.to_i < @current_attachment.body.decoded.size)

          return false
        end

      elsif Extension.document.include?(ext) && @user_filters.documents_filters

        # allowed extensions
        unless @user_filters.documents_extensions.include?(ext)
          return false
        end

        # check file size
        if (!@user_filters.documents_min_size.nil? && @user_filters.documents_min_size > @current_attachment.body.decoded.size) ||
            (!@user_filters.documents_max_size.nil? && @user_filters.documents_max_size < @current_attachment.body.decoded.size)

          return false
        end

      end

      true
    end

    # Upload file to Google Drive
    #
    # @param filename [String] name of file in Google Drive
    def upload_file(filename)
      folder = get_folder_for_file(filename)

      temp = Tempfile.new([File.basename(@current_attachment.filename), File.extname(@current_attachment.filename)], "#{Rails.root}/tmp", encoding: 'ASCII-8BIT', binmode: true)
      temp.write @current_attachment.body.decoded
      temp.rewind
      temp.close

      convert_file = !!(@user_settings.convert_files && UserSynchronization::CONVERT_EXTENSIONS.include?(File.extname(filename)))

      result = @user_api.upload_file({ path: temp.path,
                                       title: filename,
                                       mime_type: @current_attachment.mime_type,
                                       parent_id: folder[:id],
                                       convert: convert_file })

      @files[filename] = { size: @current_attachment.body.decoded.size, link: result.data.alternate_link, parent_id: folder[:id] }
      @synchronization.add_file({ filename: filename, size: @files[filename][:size], link: @files[filename][:link], label: @current_label })
      Puub.instance.publish("user_#{@user.id}",
                            {
                                event: 'synchronization_add_file',
                                data: {
                                    id: @synchronization.id,
                                    file: {
                                        name: filename,
                                        size: number_to_human_size(@files[filename][:size]),
                                        link: @files[filename][:link]
                                    }
                                }
                            })
      temp.unlink

      @logger.debug "= File #{filename} was successful uploaded"
    end

    # Return folder for file
    #
    # @param filename [String] name of file
    # @return folder structure
    def get_folder_for_file(filename)
      ext = File.extname(filename)
      extension = @extensions[ext]

      if extension
        folder_name = extension.folder
      else
        folder_name = Extension::OTHER
      end

      if @label_folders[@current_label][:sub_folders][folder_name].nil?
        result = @user_api.create_folder(title: folder_name, parent_id: @label_folders[@current_label][:id]).data
        @label_folders[@current_label][:sub_folders][folder_name] = { id: result.id, link: result.alternate_link }
        @file_types_folders[result.id] = @current_label
      end

      @label_folders[@current_label][:sub_folders][folder_name]
    end

    # Deinitialize variables
    def deinitialize_variables
      unless @imap.disconnected?
        @imap.disconnect
      end

      @logger.debug 'Variables was successful deinitialized'
    end

    # Set status finished for synchronization and push notify for user
    def finish_synchronization
      @synchronization.set_finished_status
      Puub.instance.publish("user_#{@user.id}", { event: 'synchronization_update', data: { id: @synchronization.id, action: 'reload_page' } })

      @logger.debug 'Finish synchronization'
    end
  end
end