class UserSynchronization < ActiveRecord::Base
  include ActionView::Helpers

  require 'net/imap'
  require 'gmail_xoauth/imap_xoauth2_authenticator'

  belongs_to :user
  has_many :user_synchronization_files, dependent: :destroy

  STATUS_ERROR = 0
  STATUS_INPROCESS = 1
  STATUS_FINISHED = 2
  STATUS_TEXT = ['Error', 'In process', 'Finished']

  scope :error, -> { where(status: UserSynchronization::STATUS_ERROR) }
  scope :inprocess, -> { where(status: UserSynchronization::STATUS_INPROCESS) }
  scope :finished, -> { where(status: UserSynchronization::STATUS_FINISHED) }

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
    user_synchronization_files.create!({ filename: params[:filename], size: params[:size], link: params[:link] })
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
      @user = user
      @user_api = @user.api

      @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
      @imap.authenticate('XOAUTH2', @user.email, @user_api.tokens[:access_token])

      @emails = Hash.new
      @files = Hash.new
      @folders = Hash.new

      puts '*** Variables was successful initialized'
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

      puts '*** Labels and mails ids was successful loaded'
    end

    def process_folders_and_files
      items = @user_api.load_files.data.items

      items.each do |item|
        if item.mime_type == Google::API::FOLDER_MIME
          if item.title == 'Attachments.IO' && item.parents[0].is_root
            @main_folder = { id: item.id, link: item.alternate_link }
          else
            @folders[item.title] = {id: item.id, parent_id: item.parents[0].id, link: item.alternate_link}
          end
        else
          @files[item.title] = { size: item.file_size, link: item.alternate_link }
        end
      end

      if @main_folder.nil?
        result = @user_api.create_folder(title: 'Attachments.IO').data
        @main_folder = { id: result.id, link: result.alternate_link }
      end

      puts '*** Folders and files was successful processed'
    end

    def process_label(label)
      if @folders[label].nil? || @folders[label][:parent_id] != @main_folder[:id]
        result = @user_api.create_folder(title: label, parent_id: @main_folder[:id])
        @folders[label] = { id: result.data.id, parent_id: @main_folder[:id], link: result.data.alternate_link }
      end

      @imap.select(label)

      puts "*** Label #{label} was successful processed"
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

      puts "*** Email: #{mail.subject} was successful processed"
    end

    def process_attachment(mail, attachment, label)
      filename = generate_filename(mail, attachment)

      puts "*** Attachment: #{filename}"

      if is_uploaded(filename, attachment)
        puts "*** File already uploaded #{filename}"
        #@synchronization.add_file(filename: filename, size: @files[filename][:size], link: @files[filename][:link], status: SynchronizationFile::SKIPPED)

        return
      end

      upload_file(filename, attachment, label)
    end

    def generate_filename(mail, attachment)
      if mail.subject.nil?
        Russian.translit(attachment.filename)
      else
        Russian.translit(mail.subject) + ' - ' + Russian.translit(attachment.filename)
      end
    end

    def is_uploaded(filename, attachment)
      true if !@files[filename].nil? and (attachment.body.decoded.size == @files[filename][:size])
    end

    def upload_file(filename, attachment, label)
      temp = Tempfile.new([File.basename(attachment.filename), File.extname(attachment.filename)], "#{Rails.root}/tmp", encoding: 'ASCII-8BIT', binmode: true)
      temp.write attachment.body.decoded
      temp.rewind
      temp.close

      result = @user_api.upload_file({ path: temp.path,
                                       title: filename,
                                       mime_type: attachment.mime_type,
                                       parent_id: @folders[label][:id] })

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

      puts "*** File #{filename} was successful uploaded"
    end

    def deinitialize_variables
      unless @imap.disconnected?
        @imap.disconnect
      end

      puts '*** Variables was successful deinitialized'
    end

    def finish_synchronization
      update_attributes({ status: STATUS_FINISHED, finished_at: Time.now.to_i })
      Puub.instance.publish("user_#{@user.id}", { event: 'synchronization_update', data: { id: id, action: 'reload_page' } })

      puts '*** Finish synchronization'
    end
end
