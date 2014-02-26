module Synchronization
  require 'puub'
  require 'benchmark'
  require 'transliteration'

  # Statuses of synchronizations
  WAITING = 0
  INPROCESS = 1
  ERROR = 2
  SUCCESS = 3
  FIXED = 4

  # List of convertible extensions for google drive
  CONVERT_EXTENSIONS = %w(.doc .docx .html .txt .rtf .xls .xlsx .ods .csv .tsv .tab .ppt .pps .pptx)

  class Run

    def initialize(user_id, params = {})
      @started_at = Time.now

      @user = User.find_by_id(user_id)
      @user_settings = @user.settings
      @user.sync.update_attributes({ started_at: @started_at,
                                     status: Synchronization::INPROCESS })

      @params = {}
      params.each do |key, value|
        @params[key.to_sym] = value
      end
      @params = DEFAULT_PARAMS.merge(@params)

      if Rails.env.development?
        @params[:debug] = true
      end

      if @params[:debug]
        @params[:logging] = true
      end

      if @params[:logging] || @user_settings.logging
        @logger = Logger.new("log/sync_#{@user.email}.log")

        @logger.debug '==========================================================='
        @logger.debug "START: #{Time.now.to_formatted_s(:long)}"
      end

      start

    rescue => e
      if @params[:logging]
        @logger.error "ERROR: #{e.message}"
      end

      logger = Logger.new('log/sync_errors.log', 10, 1024000)
      logger.error '============================================================='
      logger.error "Account: #{@user.email}"
      logger.error "Started at: #{@started_at.to_formatted_s(:long)}"
      logger.error "ERROR: #{e.message}"
      logger.error "BACKTRACE: #{e.backtrace}"

      finish(true)
    end

    private

    DEFAULT_PARAMS = {
        puub: true,
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
        finish

        return
      end

      drive_get_folders

      @emails.each do |label, emails|
        process_label(label)

        @current_label_emails.each do |email|
          process_email(email)
        end

        upload_label_attachments
      end

      update_last_sync
      finish
    end

    def imap_get_emails
      started_at = Time.now

      @emails = {}
      email_count = 0
      @user_api = @user.api

      @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
      @imap.authenticate('XOAUTH2', @user.email, @user_api.tokens[:access_token])

      if @params[:before_date]
        search_query = "X-GM-RAW \"has:attachment before:#{@params[:before_date].to_i}\""
      else
        if @user.last_sync.nil?
          time = Time.now - 2.weeks
        else
          time = Time.at(@user.last_sync)
        end

        search_query = "X-GM-RAW \"has:attachment after:#{time.to_i}\""
      end

      @imap.list('', '%').to_a.each do |label|
        next if label.attr.include?(:Noselect)

        @imap.examine(label.name)
        emails = @imap.search(search_query, 'UTF-8')

        next if emails.empty?

        @emails[label.name] = emails
        email_count += emails.count
      end

      @user.sync.update_attribute(:email_count, email_count)

      if @params[:puub]
        $puub.publish_for_user(@user, { event: :update_email_count, data: { email_count: email_count }.to_json })
      end

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
        if !folder.parents[0].nil? && folder.parents[0].id == @main_folder[:id]
          @folders[folder.title] = { id: folder.id, link: folder.alternate_link, sub_folders: {} }
          helper_folders[folder.id] = folder.title
        end
      end

      unless @folders.empty?
        folders.each do |folder|
          if !folder.parents[0].nil? && helper_folders[folder.parents[0].id]
            @folders[helper_folders[folder.parents[0].id]][:sub_folders][folder.title] = { id: folder.id, link: folder.alternate_link }
          end
        end
      end

      @files = @user.files_for_sync

      if @params[:puub]
        $puub.publish_for_user(@user, { event: :drive_folders_loaded })
      end

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

      if @params[:puub]
        $puub.publish_for_user(@user, { event: :loading_label, data: { label: @current_label }.to_json })
      end

      @attachments = []
      @imap.examine(label)
      @current_label = replace_label_name(label)

      if @folders[@current_label].nil?
        result = @user_api.create_folder(title: @current_label, parent_id: @main_folder[:id])
        @folders[@current_label] = { id: result.data.id, link: result.data.alternate_link, sub_folders: {} }

        if @params[:logging]
          @logger.debug "DRIVE: Folder for label created: #{@current_label}"
        end
      end

      if @params[:puub]
        $puub.publish_for_user(@user, { event: :start_fetching_emails, data: {}.to_json })
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

      if @params[:puub]
        $puub.publish_for_user(@user, { event: :finish_fetching_emails, data: {}.to_json })
      end

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

      email = Email.where(subject: @current_email.subject, user_id: @user.id).limit(1).first

      if email.nil?
        @current_mail_object = @user.emails.create({
                                                       label: @current_label,
                                                       subject: @current_email.subject,
                                                       from: from,
                                                       to: to,
                                                       date: @current_email.date.to_i
                                                   })
      else
        email.update_attribute(:date, @current_email.date.to_i)
        @current_mail_object = email
      end

      if @params[:puub]
        $puub.publish_for_user(@user, { event: :process_email, data: @current_mail_object.to_json })
      end

      @current_email.attachments.each do |attachment|
        process_attachment(attachment)
      end

      @user.sync.increment!(:email_parsed)

      if @params[:logging]
        @logger.debug "EMAIL: Processed: #{@current_email.subject}. Time: #{Time.now - started_at} sec."
      end
    end

    def process_attachment(attachment)
      @current_attachment = attachment
      @current_filename = generate_filename_for_current

      if already_uploaded
        file = @current_mail_object.files.create({
                                              filename: @current_filename,
                                              size: @files[@current_filename][:size],
                                              link: @files[@current_filename][:link],
                                              ext: File.extname(@current_filename),
                                              status: EmailFile::ALREADY_UPLOADED
                                          })

        if @params[:puub]
          $puub.publish_for_user(@user, { event: :attachment_upload, data: file.to_json })
        end

        if @params[:logging]
          @logger.debug "ATTACHMENT: Already uploaded: #{@current_filename}"
        end

        return
      end

      add_current_attachment
    end

    def already_uploaded
      if @files[@current_filename] &&
         @files[@current_filename][:label] == @current_label &&
         @files[@current_filename][:size] == @current_attachment.body.decoded.size

        return true
      end

      false
    end

    def add_current_attachment
      folder = get_folder_type_for_file(@current_filename, @current_label)

      filename = @current_filename
      attachment = @current_attachment

      temp = Tempfile.new([File.basename(filename), File.extname(filename)], "#{Rails.root}/tmp", encoding: 'ASCII-8BIT', binmode: true)
      temp.write(attachment.body.decoded)
      temp.rewind
      temp.close

      convert_file = !!(@user_settings.convert_files && CONVERT_EXTENSIONS.include?(File.extname(filename)))

      @attachments << { path: temp.path,
                        title: filename,
                        mime_type: attachment.mime_type,
                        parent_id: folder[:id],
                        convert: convert_file,
                        temp_file: temp,
                        email: @current_mail_object }

      @files[filename] = { label: @current_label, size: @current_attachment.body.decoded.size }
    end

    def upload_label_attachments
      threads = []
      started_at = Time.now

      @attachments.each do |attachment|
        threads << Thread.new do

          result = @user_api.upload_file(attachment)
          @files[attachment[:title]][:link] = result.data.alternate_link

          file = attachment[:email].files.create({
                                        filename: attachment[:title],
                                        size: @files[attachment[:title]][:size],
                                        link: @files[attachment[:title]][:link],
                                        ext: File.extname(attachment[:title]),
                                        status: EmailFile::UPLOADED
                                    })

          # TODO: fix it (not connected to user)
          EmailFile.where(filename: attachment[:title], size: @files[attachment[:title]][:size]).update_all(link: @files[attachment[:title]][:link])

          attachment[:temp_file].unlink

          if @params[:puub]
            $puub.publish_for_user(@user, { event: :attachment_upload, data: file.to_json })
          end

          if @params[:logging]
            @logger.debug "ATTACHMENT: Uploaded: #{attachment[:title]}"
          end
        end
      end

      threads.each(&:join)

      if @params[:logging]
        @logger.debug "DRIVE: All attachments for label #{@current_label} is uploaded. Time: #{Time.now - started_at}"
      end
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
      filename = Transliteration.transliterate(@current_attachment.filename)

      if @user_settings.subject_in_filename && !@current_email.subject.empty?
        subject = Transliteration.transliterate(@current_email.subject)
        filename = "#{subject} - #{filename}"
      end

      filename
    end

    def update_last_sync
      @user.update_attribute(:first_sync_at, @started_at.to_i) if @user.last_sync.nil?
      @user.update_attribute(:last_sync, @started_at.to_i)
    end

    def finish(error = false)
      if error
        previous_status = Synchronization::ERROR
      else
        previous_status = Synchronization::SUCCESS
      end

      @user.sync.update_attributes(status: Synchronization::WAITING,
                                   email_count: 0,
                                   email_parsed: 0,
                                   previous_status: previous_status,
                                   started_at: nil)

      if @imap && !@imap.disconnected?
        @imap.disconnect
      end

      if @params[:puub]
        $puub.publish_for_user(@user, { event: :finish, data: { status: previous_status }.to_json })
      end

      if @params[:logging]
        @logger.debug "Synchronization finished. Time: #{Time.now - @started_at} sec."
      end
    end
  end
end