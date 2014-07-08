class Synchronization < ActiveRecord::Base
  require 'sync'

  belongs_to :user

  enum status: {
      waiting: Sync::WAITING,
      inprocess: Sync::INPROCESS
  }

  def self.problematic
    problematic = []

    where(status: Sync::INPROCESS).each do |sync|
      if sync.started_at.nil? || Time.now.to_i - sync.started_at.to_i > 1.hours.to_i
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
      sync.update_attributes(status: Sync::WAITING,
                             email_count: 0,
                             email_parsed: 0,
                             previous_status: Sync::FIXED,
                             started_at: nil)

      puts "[#{Time.now.to_formatted_s(:long)}]: #{sync.user.email} fixed."
    end
  end
end
