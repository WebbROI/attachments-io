class UserEmail < ActiveRecord::Base
  belongs_to :user
  has_many :user_email_files, dependent: :destroy

  #
  # Aliases
  #

  def files
    user_email_files
  end
end
