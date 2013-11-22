module Synchronization
  class Process
    def self.add(user_id)
      @@inprocess << user_id unless @@inprocess.include?(user_id)
    end

    def self.remove(user_id)
      @@inprocess.delete(user_id) if @@inprocess.include?(user_id)
    end

    def self.check(user_id)
      @@inprocess.include?(user_id)
    end

    def self.list
      @@inprocess.to_a
    end

    private

    @@inprocess = []
  end
end