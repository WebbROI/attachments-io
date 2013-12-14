desc 'Start synchronization for all users. Run every 10 minutes.'
task start_synchronizations: :environment do
  syncs = UserSynchronization.select('user_id').waiting.to_a
  users = User.find(syncs.map(&:user_id).uniq)

  users.each do |user|
    puts "#{user.email} sync started.."
    user.start_synchronization({ rake: true }, true)
    user.start_synchronization({ rake: true }, true)
    user.start_synchronization({ rake: true }, true)

    Resque.enqueue(TestWorker)
    Resque.enqueue(TestWorker)
    Resque.enqueue(TestWorker)
  end
end