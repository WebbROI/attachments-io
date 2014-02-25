class StartSynchronization
  require 'synchronization/run'

  @queue = :sync_queue

  def self.perform(user_id, params)
    i = 0
    begin
      i += 1
      user = User.find_by_id(user_id)
    end while user.nil? || i < 100

    Synchronization::Run.new(user, params)
  end
end