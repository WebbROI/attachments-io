desc 'Start synchronization for all users. Run every 10 minutes.'
task start_synchronizations: :environment do
  syncs = UserSynchronization.select('user_id').waiting.to_a
  not_active = UserSettings.select('user_id').not_active.to_a

  users = User.find((syncs.map(&:user_id) + not_active.map(&:user_id)).uniq)

  if users.empty?
    puts 'Nothing to synchronize..'
  else
    users.each do |user|
      puts "#{user.email} sync started.."
      user.start_synchronization({ rake: true }, true)
    end
  end
end

desc 'Fix broken synchronizations'
task fix_synchronizations: :environment do
  UserSynchronization.fix_problematic
end