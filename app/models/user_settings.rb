class UserSettings < ActiveRecord::Base
  belongs_to :user

  scope :active, -> { where(active: true) }
  scope :not_active, -> { where(active: false) }
end
