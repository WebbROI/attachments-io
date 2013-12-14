class StartSynchronization
  require 'synchronization/run'

  @queue = :sync_queue

  def self.perform(user_id, params)
    Synchronization::Run.new(User.find(user_id), params)
  end
end