module Synchronization
  class Process

    # Add user to now synchronizes list
    # @param [Integer] user id
    def self.add(user_id)
      @@inprocess << user_id unless @@inprocess.include?(user_id)
    end

    # Remove user from now synchronizes list
    # @param [Integer] user id
    def self.remove(user_id)
      @@inprocess.delete(user_id) if @@inprocess.include?(user_id)
    end

    # Check user in the list of synchronizes
    # @param [Integer] user id
    def self.check(user_id)
      @@inprocess.include?(user_id)
    end

    # Get list of all synchronizes users
    def self.list
      @@inprocess.to_a
    end

    private

    @@inprocess = []
  end
end