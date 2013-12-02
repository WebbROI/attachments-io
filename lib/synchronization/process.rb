module Synchronization

  # Statuses of synchronizations
  INPROCESS = 'inprocess'
  WAITING = 'waiting'

  class Process

    # Add user to now synchronizes list
    # @param [Integer] user id
    # @param [Hash] information about process
    def self.add(user_id, data = {})
      @@inprocess[user_id] = data unless @@inprocess[user_id]
    end

    # Get information about sync for user
    # @param [Integer] user id
    def self.get(user_id)
      @@inprocess[user_id] if @@inprocess[user_id]
    end

    # Update info about process
    # @param [Integer] user id
    # @param [Symbol] field name
    # @param [*] value of field
    def self.update(user_id, field_name, value)
      @@inprocess[user_id][field_name] = value if @@inprocess[user_id]
    end

    # Remove user from now synchronizes list
    # @param [Integer] user id
    def self.remove(user_id)
      @@inprocess.delete(user_id) if @@inprocess[user_id]
    end

    # Check user in the list of synchronizes
    # @param [Integer] user id
    def self.check(user_id)
      @@inprocess[user_id]
    end

    # Get list of all synchronizes users
    def self.list
      @@inprocess.to_a
    end

    private

    @@inprocess = {}
  end
end