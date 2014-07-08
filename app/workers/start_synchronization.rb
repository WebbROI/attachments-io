class StartSynchronization
  require 'sync'

  @queue = :sync_queue

  def self.perform(user_id, params)
    Sync::Run.new(user_id, params)
  end
end