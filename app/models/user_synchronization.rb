class UserSynchronization < ActiveRecord::Base
  belongs_to :user

  scope :waiting, -> { where(status: Synchronization::WAITING) }
  scope :inprocess, -> { where(status: Synchronization::INPROCESS) }

  def inprocess!
    update_attribute(:status, Synchronization::INPROCESS)
  end

  def inprocess?
    status == Synchronization::INPROCESS
  end

  def waiting!
    update_attribute(:status, Synchronization::WAITING)
  end

  def waiting?
    status == Synchronization::WAITING
  end
end
