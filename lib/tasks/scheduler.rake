namespace :sync do
  desc 'Start synchronization for all users. Run every 10 minutes.'
  task start: :environment do
    syncs = Synchronization.select('user_id').waiting.to_a
    not_active = UserSettings.select('user_id').not_active.to_a

    users = User.find((syncs.map(&:user_id) + not_active.map(&:user_id)).uniq)

    if users.empty?
      puts "[#{Time.now.to_formatted_s(:long)}]: Nothing to synchronize.."
    else
      puts "[#{Time.now.to_formatted_s(:long)}]: Synchronized:"
      users.each do |user|
        user.start_synchronization({ rake: true })
        puts "        #{user.email}"
      end
    end
  end

  desc 'Fix broken synchronizations'
  task fix: :environment do
    Synchronization.fix_problematic
  end
end