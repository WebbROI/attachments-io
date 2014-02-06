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

  def self.problematic
    problematic = []

    where(status: Synchronization::INPROCESS).includes(:user).each do |sync|
      if sync.user.last_sync.to_i - Time.now.to_i > 1.hours
        problematic << sync
      end
    end

    problematic
  end

  def self.fix_problematic(users = nil)
    if users.nil?
      users = self.problematic
    end

    users.each do |sync|
      sync.update_attributes({ status: Synchronization::WAITING,
                               previous_status: Synchronization::FIXED })
    end
  end
end
