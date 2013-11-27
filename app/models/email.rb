class Email < ActiveRecord::Base
  belongs_to :user
  has_many :email_files, dependent: :destroy

  #
  # Aliases
  #

  def files
    email_files
  end
end
