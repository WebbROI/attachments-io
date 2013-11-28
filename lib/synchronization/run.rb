module Synchronization
  # @author Andrew Emelianenko

  # List of convertible extensions for google drive
  CONVERT_EXTENSIONS = %w(.doc .docx .html .txt .rtf .xls .xlsx .ods .csv .tsv .tab .ppt .pps .pptx)

  # Statuses of synchronizations
  INPROCESS = 'inprocess'
  WAITING = 'waiting'

  class Run
    include ActionView::Helpers

    # Start synchronization for user
    #
    # @param user [User]
    # @param params hash of parameters
    def initialize(user, params = {})
      return if (Synchronization::Process.check(user.id))
      Synchronization::Process.add(user.id,
                                   {
                                       status: :inprocess,
                                       started_at: nil,
                                       email_count: nil,
                                       email_parsed: nil
                                   })

      @user = user
      @params = params

      if @params[:debug] == true || @params[:rake] == true
        thread
      else
        Thread.new do
          thread
        end
      end
    end

    private

    @user
    @user_api
    @user_settings

    @emails
    @files
    @label_folders
    @file_types_folders

    @extensions

    @current_label
    @current_mail
    @current_mail_object
    @current_attachment

    @started_at

    @logger

    # Main function, can start without thread
    def thread
      initialize_variables

      load_labels_and_emails

      # stop sync if we don't have emails with attachments
      if @emails.empty?
        finish_synchronization
        deinitialize_variables
        return
      end

      load_folders_and_files

      # sync emails
      @emails.each do |label, emails|
        @current_label = replace_label_name(label)
        process_current_label
        @imap.select(label)

        emails.each do |email_id|
          process_email(email_id)
        end
      end

      finish_synchronization
      deinitialize_variables
    rescue => e
      @logger.error "[ERROR] #{e.message}"
      deinitialize_variables
    end

    # Initialize variables and IMAP connection
    def initialize_variables
      @started_at = Time.now.to_i
      Synchronization::Process.update(@user.id, :started_at, @started_at)

      @logger = Logger.new('log/synchronization.log')
      @logger.debug "#{@user.email} " +  '==================== [SYNCHRONIZATION] ===================='

      @user_api = @user.api
      @user_settings = @user.settings

      @emails = {}
      @files = {}
      @label_folders = {}
      @file_types_folders = {}

      @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
      @imap.authenticate('XOAUTH2', @user.email, @user_api.tokens[:access_token])

      @extensions = Extension.all_hash

      @logger.debug "#{@user.email} " +  'Variables initialized'
    end

    # Load labels and emails
    def load_labels_and_emails
      email_count = 0

      if @user.last_sync.nil?
        search_query = 'X-GM-RAW has:attachment'
      else
        time = Time.at(@user.last_sync)
        search_query = "X-GM-RAW \"has:attachment after:#{time.year}/#{time.month}/#{time.day}\""
      end

      @imap.list('', '%').to_a.each do |label|
        next unless label.attr.find_index(:Noselect).nil?

        @imap.select(label.name)
        emails = @imap.search(search_query)

        next if emails.empty?

        @emails[label.name] = emails
        email_count += emails.count
      end

      Synchronization::Process.update(@user.id, :email_count, email_count)

      @logger.debug "#{@user.email} " +  'Labels and mails ids was successful loaded'
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
      #all_files = @user_api.load_files(is_folder: false).data.items
      #all_files.each do |file|
      #  if file.parents[0] && @file_types_folders[file.parents[0].id]
      #    @files[file.title] = { size: file.file_size, link: file.alternate_link, parent_id: file.parents[0].id }
      #  end
      #end

      @files = @user.files_for_sync

      @logger.debug "#{@user.email} " +  'Folders and files was successful processed'
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

      @logger.debug "#{@user.email} " +  "Label #{@current_label} was selected"
    end

    # Load email from Google Mail and process attachments
    #
    # @param email_id [Integer] id of email for current label
    def process_email(email_id)
      @current_mail = Mail.read_from_string(@imap.fetch(email_id, 'RFC822')[0].attr['RFC822'])

      if @current_mail.from.is_a?(Array)
        from = @current_mail.from.join(',')
      else
        from = @current_mail.from.to_s
      end

      if @current_mail.to.is_a?(Array)
        to = @current_mail.to.join(',')
      else
        to = @current_mail.to.to_s
      end

      @current_mail_object = @user.emails.create!({
                                                       label: @current_label,
                                                       subject: @current_mail.subject,
                                                       from: from,
                                                       to: to,
                                                       date: @current_mail.date.to_i
                                                   })

      @current_mail.attachments.each do |attachment|
        process_attachment(attachment)
      end

      Synchronization::Process.update(@user.id,
                                      :email_parsed,
                                      Synchronization::Process.get(@user.id)[:email_parsed].to_i + 1)

      @logger.debug "#{@user.email} " +  "Email #{@current_mail.subject} was successful processed"
    end

    # Generate filename, check is uploaded file and upload file
    #
    # @param attachment [Mail::Part] attachment from Mail
    def process_attachment(attachment)
      @current_attachment = attachment
      filename = generate_filename(@current_attachment)

      @logger.debug "#{@user.email} " +  "= Attachment \"#{filename}\" initialized"



      if is_uploaded(filename)
        file_status = EmailFile::ALREADY_UPLOADED

        @logger.debug "#{@user.email} " +  '- File already uploaded'
      else
        upload_file(filename)
        file_status = EmailFile::UPLOADED

        @logger.debug "#{@user.email} " +  "+ File #{filename} was successful uploaded"
      end

      @current_mail_object.files.create({ filename: filename,
                                          size: @files[filename][:size],
                                          link: @files[filename][:link],
                                          ext: File.extname(filename),
                                          status: file_status })
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
      if @files[filename] &&
         @files[filename][:label] == @current_label &&
         @files[filename][:size] == @current_attachment.body.decoded.size

        return true
      end

      false

      #if !@files[filename].nil? &&
      #   !@file_types_folders.nil? &&
      #   @file_types_folders[@files[filename][:parent_id]] == @current_label# &&
      #   #(Synchronization::CONVERT_EXTENSIONS.include?(File.extname(filename)) ||
      #   #(!Synchronization::CONVERT_EXTENSIONS.include?(File.extname(filename)) &&
      #   #@current_attachment.body.decoded.size == @files[filename][:size]))
      #
      #  return true
      #end
      #
      #false
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

      convert_file = !!(@user_settings.convert_files && Synchronization::CONVERT_EXTENSIONS.include?(File.extname(filename)))

      result = @user_api.upload_file({ path: temp.path,
                                       title: filename,
                                       mime_type: @current_attachment.mime_type,
                                       parent_id: folder[:id],
                                       convert: convert_file })

      temp.unlink

      @files[filename] = { size: @current_attachment.body.decoded.size, link: result.data.alternate_link, label: @current_label, parent_id: folder[:id] }
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

    # Update last sync
    def finish_synchronization
      @user.update_attribute(:last_sync, @started_at)
    end

    # Deinitialize variables
    def deinitialize_variables
      if @imap && !@imap.disconnected?
        @imap.disconnect
      end

      @logger.debug "#{@user.email} " +  "Time elapsed: #{Time.now.to_i - @started_at} sec."
      @logger.debug "#{@user.email} " +  'Variables was successful deinitialized'

      Synchronization::Process.remove(@user.id)
    end
  end
end