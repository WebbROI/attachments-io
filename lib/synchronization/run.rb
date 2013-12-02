module Synchronization
  require 'benchmark'
  require 'transliteration'

  # List of convertible extensions for google drive
  CONVERT_EXTENSIONS = %w(.doc .docx .html .txt .rtf .xls .xlsx .ods .csv .tsv .tab .ppt .pps .pptx)

  class Run

    def initialize(user, params = {})
      return if Synchronization::Process.check(user.id)
      Synchronization::Process.add(user.id, { status: Synchronization::INPROCESS })

      @started_at = Time.now

      @user = user
      @params = DEFAULT_PARAMS.merge(params)

      if @params[:debug]
        @params[:thread] = false
        @params[:logging] = true
      end

      if @params[:logging]
        #@logger = Logger.new('log/synchronization.log')
        @logger = Logger.new("log/synchronizations_#{@user.email}.log")
        @logger.debug "START: #{Time.now.to_formatted_s(:long)}"
      end

      if @params[:thread]
        Thread.new do
          start
        end
      else
        start
      end
    end

    private

    DEFAULT_PARAMS = {
        thread: true,
        debug: false,
        logging: false
    }

    def start
      imap_get_emails

      if @emails.empty?
        if @params[:logging]
          @logger.debug 'Empty emails to synchronize.'
        end

        update_last_sync
        return finish
      end

      @user_settings = @user.settings

      drive_get_folders

      @emails.each do |label, emails|
        process_label(label)

        @current_label_emails.each do |email|
          process_email(email)
        end
      end

      update_last_sync
      finish

    rescue => e
      if @params[:logging]
        @logger.error "ERROR: #{e.message}"
      end

      finish
    end

    def imap_get_emails
      started_at = Time.now

      @emails = {}
      email_count = 0
      @user_api = @user.api

      @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
      @imap.authenticate('XOAUTH2', @user.email, @user_api.tokens[:access_token])

      if @user.last_sync.nil?
        search_query = 'X-GM-RAW has:attachment'
      else
        time = Time.at(@user.last_sync)
        search_query =  "X-GM-RAW \"has:attachment after:#{time.year}/#{time.month}/#{time.day}\""
      end

      @imap.list('', '%').to_a.each do |label|
        next if label.attr.include?(:Noselect)

        @imap.examine(label.name)
        emails = @imap.search(search_query, 'UTF-8')

        next if emails.empty?

        @emails[label.name] = emails
        email_count += emails.count
      end

      Synchronization::Process.update(@user.id, :email_count, email_count)

      if @params[:logging]
        @logger.debug "IMAP: Connected and emails ids loaded. Time: #{Time.now - started_at} sec."
      end
    end

    def drive_get_folders
      started_at = Time.now

      @files = {}
      @folders = {}
      @main_folder = nil

      folders = @user_api.load_files(is_folder: true).data.items

      folders.each do |folder|
        if folder.title == IO_ROOT_FOLDER && !!folder.parents[0].is_root
          @main_folder = { id: folder.id, link: folder.alternate_link }
          break
        end
      end

      if @main_folder.nil?
        result = @user_api.create_folder(title: IO_ROOT_FOLDER).data
        @main_folder = { id: result.id, link: result.alternate_link }

        if @params[:logging]
          @logger.debug "Main folder created: #{IO_ROOT_FOLDER}"
        end

        return
      end

      helper_folders = {}
      folders.each do |folder|
        if folder.parents[0].id == @main_folder[:id]
          @folders[folder.title] = { id: folder.id, link: folder.alternate_link, sub_folders: {} }
          helper_folders[folder.id] = folder.title
        end
      end

      unless @folders.empty?
        folders.each do |folder|
          if helper_folders[folder.parents[0].id]
            @folders[helper_folders[folder.parents[0].id]][:sub_folders][folder.title] = { id: folder.id, link: folder.alternate_link }
          end
        end
      end

      @files = @user.files_for_sync

      if @params[:logging]
        @logger.debug "DRIVE: Folders and files was loaded. Time: #{Time.now - started_at} sec."
      end
    end

    # Replace label name
    #
    # @param label_name [String] label name in Google Mail
    # @@return [String] folder name in Google Drive
    def replace_label_name(label_name)
      case label_name
        when 'INBOX'
          '@ttachments.io'
        else
          label_name
      end
    end

    def process_label(label)
      started_at = Time.now

      @imap.examine(label)
      @current_label = replace_label_name(label)

      if @folders[@current_label].nil?
        result = @user_api.create_folder(title: @current_label, parent_id: @main_folder[:id])
        @folders[@current_label] = { id: result.data.id, link: result.data.alternate_link, sub_folders: {} }

        if @params[:logging]
          @logger.debug "DRIVE: Folder for label created: #{@current_label}"
        end
      end

      threads = []
      @current_label_emails = []

      @emails[label].each do |email_id|
        threads << Thread.new {
          # fix imap bug
          begin
            mail = @imap.fetch(email_id, 'RFC822')
          end while mail.nil?

          @current_label_emails << Mail.read_from_string(mail[0].attr['RFC822'])
        }
      end

      threads.each(&:join)

      if @params[:logging]
        @logger.debug "IMAP: Emails for label \"#{@current_label}\" downloaded. Time: #{Time.now - started_at} sec."
      end
    end

    def process_email(email)
      started_at = Time.now

      @current_email = email

      if @current_email.from.is_a?(Array)
        from = @current_email.from.join(',')
      else
        from = @current_email.from.to_s
      end

      if @current_email.to.is_a?(Array)
        to = @current_email.to.join(',')
      else
        to = @current_email.to.to_s
      end

      @current_mail_object = @user.emails.create({
                                                      label: @current_label,
                                                      subject: @current_email.subject,
                                                      from: from,
                                                      to: to,
                                                      date: @current_email.date.to_i
                                                  })

      @current_email.attachments.each do |attachment|
        process_attachment(attachment)
      end

      if @params[:logging]
        @logger.debug "EMAIL: Processed: #{@current_email.subject}. Time: #{Time.now - started_at} sec."
      end
    end

    def process_attachment(attachment)
      @current_attachment = attachment
      @current_filename = generate_filename_for_current

      if already_uploaded
        @current_mail_object.files.create({
                                              filename: @current_filename,
                                              size: @files[@current_filename][:size],
                                              link: @files[@current_filename][:link],
                                              ext: File.extname(@current_filename),
                                              status: EmailFile::ALREADY_UPLOADED
                                          })

        if @params[:logging]
          @logger.debug "ATTACHMENT: Already uploaded: #{@current_filename}"
        end

        return
      end

      upload_current_attachment
    end

    def already_uploaded
      if @files[@current_filename] &&
         @files[@current_filename][:label] == @current_label &&
         @files[@current_filename][:size] == @current_attachment.body.decoded.size

        return true
      end

      false
    end

    def upload_current_attachment
      folder = get_folder_type_for_file(@current_filename, @current_label)
      @files[@current_filename] = { label: @current_label, size: @current_attachment.body.decoded.size }

      filename = @current_filename
      attachment = @current_attachment
      email = @current_mail_object

      if @params[:logging]
        @logger.debug "ATTACHMENT: Uploading: #{filename}"
      end

      temp = Tempfile.new([File.basename(filename), File.extname(filename)], "#{Rails.root}/tmp", encoding: 'ASCII-8BIT', binmode: true)
      temp.write(attachment.body.decoded)
      temp.rewind
      temp.close

      convert_file = !!(@user_settings.convert_files && CONVERT_EXTENSIONS.include?(File.extname(filename)))

      result = @user_api.upload_file({ path: temp.path,
                                       title: filename,
                                       mime_type: attachment.mime_type,
                                       parent_id: folder[:id],
                                       convert: convert_file })

      @files[filename][:link] = result.data.alternate_link

      if result.data.alternate_link.nil? || result.data.alternate_link.empty?
        result.data.to_yaml
      end

      email.files.create({
                             filename: filename,
                             size: @files[filename][:size],
                             link: @files[filename][:link],
                             ext: File.extname(filename),
                             status: EmailFile::UPLOADED
                         })

      temp.unlink
    end

    def get_folder_type_for_file(filename, label)
      unless defined? @extensions
        @extensions = Extension.all_hash
      end

      ext = File.extname(filename)
      extension = @extensions[ext]

      if extension
        folder_name = extension.folder
      else
        folder_name = Extension::OTHER
      end

      if @folders[label][:sub_folders][folder_name].nil?
        result = @user_api.create_folder(title: folder_name, parent_id: @folders[label][:id]).data
        @folders[label][:sub_folders][folder_name] = { id: result.id, link: result.alternate_link }

        if @params[:logging]
          @logger.debug "DRIVE: Sub-folder \"#{folder_name}\" for label \"#{label}\" created."
        end
      end

      @folders[@current_label][:sub_folders][folder_name]
    end

    def generate_filename_for_current
      filename = @current_attachment.filename
      Transliteration.transliterate(filename)
    end

    def update_last_sync
      @user.update_attribute(:last_sync, @started_at.to_i)
    end

    def finish
      @imap.disconnect

      if @params[:logging]
        @logger.debug "Synchronization finished. Time: #{Time.now - @started_at} sec."
      end
    end
  end
end