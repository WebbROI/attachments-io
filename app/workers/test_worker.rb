class TestWorker
  @queue = :test_queue

  def self.perform
    sleep 10
  end
end