class Email < ActiveRecord::Base
  belongs_to :user
  has_many :email_files, dependent: :destroy

  default_scope -> { order(date: :desc) }

  alias :files :email_files

  def to_s
    if subject
      subject
    else
      'No subject'
    end
  end
end
