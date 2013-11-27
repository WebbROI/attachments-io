class Email < ActiveRecord::Base
  belongs_to :user
  has_many :email_files, dependent: :destroy

  default_scope -> { order(date: :desc) }

  def to_s
    if subject
      subject
    else
      'No subject'
    end
  end

  #
  # Aliases
  #

  def files
    email_files
  end
end
