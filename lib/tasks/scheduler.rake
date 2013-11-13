namespace :scheduler do
  desc "TODO"
  task start_synchronizations: :environment do
    puts 'Synchronizations was started..'

    users = User.all

    users.each do |user|
      if user.now_synchronizes? || (user.token_expire? && !user.has_refresh_token?)
        puts "User #{user.email} skipped.."
        next
      end

      user.start_synchronization(rake: true)
    end
  end

end
