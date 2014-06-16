class Email < ActiveRecord::Base
  belongs_to :user
  has_many :email_files, dependent: :destroy

  default_scope -> { order(date: :desc) }

  # Filters
  before_validation :cut_subject

  alias :files :email_files

  def to_s
    if subject
      subject
    else
      'No subject'
    end
  end

  private
  def cut_subject
    self.subject = self.subject[0..254]
  end
end
