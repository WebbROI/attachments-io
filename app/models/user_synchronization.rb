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

    where(status: Synchronization::INPROCESS).each do |sync|
      if sync.started_at.to_i - Time.now.to_i > 1.hours
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
      sync.update_attributes(status: Synchronization::WAITING,
                             email_count: 0,
                             email_parsed: 0,
                             previous_status: Synchronization::FIXED,
                             started_at: nil)

      puts "[#{Time.now.to_formatted_s(:long)}]: #{sync.user.email} fixed."
    end
  end
end
