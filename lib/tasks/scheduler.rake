desc 'Start synchronization for all users. Makes every 10 minutes.'
task start_synchronizations: :environment do
  started_at = Time.now

  threads = []
  users = User.all

  users.each do |user|
    threads << Thread.new do
      unless user.now_synchronizes?
        started_user_at = Time.now
        puts "Start synchronization for: #{user.email}"

        sleep Random.new.rand
        user.start_synchronization(rake: true)

        puts "= End sycnhronization for: #{user.email}. Time: #{Time.now - started_user_at} sec."
      end
    end
  end

  threads.each(&:join)

  puts "All synchronization was finished at: #{Time.now - started_at} sec."
end