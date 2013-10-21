class UserSynchronization < ActiveRecord::Base
  include ActionView::Helpers

  require 'net/imap'
  require 'gmail_xoauth/imap_xoauth2_authenticator'

  belongs_to :user
  has_many :user_synchronization_files, dependent: :destroy

  default_scope -> { order(started_at: :desc) }

  scope :error, -> { where(status: UserSynchronization::STATUS_ERROR) }
  scope :inprocess, -> { where(status: UserSynchronization::STATUS_INPROCESS) }
  scope :finished, -> { where(status: UserSynchronization::STATUS_FINISHED) }

  STATUS_ERROR = 0
  STATUS_INPROCESS = 1
  STATUS_FINISHED = 2
  STATUS_TEXT = ['Error', 'In process', 'Finished']
  DEFAULT_FILENAME_FORMAT = '%subject% - %filename%'

  #
  # Helpers
  #

  def status_readable
    STATUS_TEXT[status]
  end

  def finished?
    status == STATUS_FINISHED
  end

  def inprocess?
    status == STATUS_INPROCESS
  end

  def error?
    status == STATUS_ERROR
  end

  #
  # Aliases
  #

  def files
    user_synchronization_files
  end

  #
  # Synchronization Files
  #

  def add_file(params)
    user_synchronization_files.create!({ filename: params[:filename], size: params[:size], link: params[:link], ext: File.extname(params[:filename]) })
  end

  #
  # Synchronization
  #

  def start
    initialize_variables

    load_labels_and_emails
    process_folders_and_files

    @emails.each do |label, emails|
      process_label(label)

      emails.each do |email_id|
        process_email(email_id, label)
      end
    end

    deinitialize_variables

    finish_synchronization
  end

  private
    def initialize_variables
      @logger = Logger.new('log/synchronization.log')
      @user = user
      @user_api = @user.api

      @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
      @imap.authenticate('XOAUTH2', @user.email, @user_api.tokens[:access_token])

      @emails = Hash.new
      @files = Hash.new
      @folders = Hash.new
      @label_folders = Hash.new

      @logger.debug '=========== [ START SYNCHRONIZATION ] =========== '
      @logger.debug '*** Variables was successful initialized'
    end

    def load_labels_and_emails
      email_count = 0
      last_sync = user.synchronizations.finished.last
      if last_sync.nil?
        search_query = 'X-GM-RAW has:attachment'
      else
        time = Time.at(last_sync.started_at)
        search_query = "X-GM-RAW \"has:attachment after:#{time.year}/#{time.month}/0#{time.day}\""
      end

      @imap.list('', '%').each do |label|
        next unless label.attr.find_index(:Noselect).nil?

        @imap.select(label.name)
        emails = @imap.search(search_query)

        next if emails.empty?

        @emails[label.name] = emails
        email_count += emails.count
      end

      update_attribute(:email_count, email_count)

      @logger.debug '*** Labels and mails ids was successful loaded'
    end

    def process_folders_and_files
      # get main folder
      items = @user_api.load_files(title: IO_ROOT_FOLDER, is_root: true).data.items

      if items.empty?
        result = @user_api.create_folder(title: 'Attachments.IO').data
        @main_folder = { id: result.id, link: result.alternate_link }

        return
      else
        folder = items.first
        @main_folder = { id: folder.id, link: folder.alternate_link }
      end

      # get all folders
      all_folders = @user_api.load_files(is_folder: true).data.items

      # parse label folders
      label_ids = Hash.new
      all_folders.each do |folder|
        if folder.parents[0] && folder.parents[0].id == @main_folder[:id]
          @label_folders[folder.title] = { id: folder.id, link: folder.alternate_link, sub_folders: Hash.new }
          label_ids[folder.id] = folder.title
        end
      end

      # parse file types folders
      unless @label_folders.empty?
        all_folders.each do |folder|
          if folder.parents[0] && label_ids.include?(folder.parents[0].id)
            @label_folders[label_ids[folder.parents[0].id]][:sub_folders][folder.title] = { id: folder.id, link: folder.alternate_link }
          end
        end
      end

      # get all files
      all_files = @user_api.load_files(is_folder: false).data.items
      all_files.each do |file|
        @files[file.title] = { size: file.file_size, link: file.alternate_link }
      end

      @logger.debug '*** Folders and files was successful processed'
    end

    def process_label(label)
      if @label_folders[label].nil?
        result = @user_api.create_folder(title: label, parent_id: @main_folder[:id])
        @label_folders[label] = { id: result.data.id, link: result.data.alternate_link, sub_folders: Hash.new }
      end

      @imap.select(label)

      @logger.debug "*** Label #{label} was successful processed"
    end

    def process_email(mail_id, label)
      mail = Mail.read_from_string(@imap.fetch(mail_id, 'RFC822')[0].attr['RFC822'])

      mail.attachments.each do |attachment|
        process_attachment(mail, attachment, label)
      end

      update_attribute(:email_parsed, email_parsed.to_i + 1)
      Puub.instance.publish("user_#{@user.id}",
                            {
                                event: 'progressbar',
                                data: {
                                    id: id,
                                    action: 'update',
                                    parsed: email_parsed.to_i,
                                    count: email_count.to_i
                                }
                            })

      @logger.debug "*** Email: #{mail.subject} was successful processed"
    end

    def process_attachment(mail, attachment, label)
      filename = generate_filename(mail, attachment)

      @logger.debug "*** Attachment: #{filename}"

      if is_uploaded(filename, attachment)
        @logger.debug "*** File already uploaded #{filename}"

        return
      end

      upload_file(filename, attachment, label)
    end

    def generate_filename(mail, attachment)
      Russian.translit(attachment.filename)
    end

    def is_uploaded(filename, attachment)
      true if !@files[filename].nil? and (attachment.body.decoded.size == @files[filename][:size])
    end

    def upload_file(filename, attachment, label)
      folder = get_file_folder(filename, attachment, label)

      temp = Tempfile.new([File.basename(attachment.filename), File.extname(attachment.filename)], "#{Rails.root}/tmp", encoding: 'ASCII-8BIT', binmode: true)
      temp.write attachment.body.decoded
      temp.rewind
      temp.close

      result = @user_api.upload_file({ path: temp.path,
                                       title: filename,
                                       mime_type: attachment.mime_type,
                                       parent_id: folder[:id] })

      @files[filename] = { size: attachment.body.decoded.size, link: result.data.alternate_link }
      add_file({ filename: filename, size: @files[filename][:size], link: @files[filename][:link] })
      Puub.instance.publish("user_#{@user.id}",
                            {
                                event: 'synchronization_add_file',
                                data: {
                                    id: id,
                                    file: {
                                        name: filename,
                                        size: number_to_human_size(@files[filename][:size]),
                                        link: @files[filename][:link]
                                    }
                                }
                            })
      temp.unlink

      @logger.debug "*** File #{filename} was successful uploaded"
    end

    def get_file_folder(filename, attachment, label)
      ext = File.extname(filename)
      extension = Extension.find_by_extension(ext)

      if extension
        folder_name = extension.folder
      else
        folder_name = Extension::OTHER
      end

      if @label_folders[label][:sub_folders][folder_name].nil?
        result = @user_api.create_folder(title: folder_name, parent_id: @label_folders[label][:id]).data
        @label_folders[label][:sub_folders][folder_name] = { id: result.id, link: result.alternate_link }
      end

      @label_folders[label][:sub_folders][folder_name]
    end

    def deinitialize_variables
      unless @imap.disconnected?
        @imap.disconnect
      end

      @logger.debug '*** Variables was successful deinitialized'
    end

    def finish_synchronization
      update_attributes({ status: STATUS_FINISHED, finished_at: Time.now.to_i })
      Puub.instance.publish("user_#{@user.id}", { event: 'synchronization_update', data: { id: id, action: 'reload_page' } })

      @logger.debug '*** Finish synchronization'
    end
end
