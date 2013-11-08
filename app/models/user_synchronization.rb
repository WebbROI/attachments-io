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

  CONVERT_EXTENSIONS = %w(.doc .docx .html .txt .rtf .xls .xlsx .ods .csv .tsv .tab .ppt .pps .pptx)

  #
  # Helpers
  #

  def self.init(user_id)
    create!(
        user_id: user_id,
        status: STATUS_INPROCESS,
        started_at: Time.now.to_i
    )
  end

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

  def set_finished_status
    update_attributes({
                          status: STATUS_FINISHED,
                          finished_at: Time.now.to_i
                      })
  end

  def set_error_status(message = '')
    update_attributes({
                          status: STATUS_ERROR,
                          error_message: message
                      })
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
    user_synchronization_files.create!({ filename: params[:filename], size: params[:size], link: params[:link], ext: File.extname(params[:filename]), label: params[:label] })
  end
end
