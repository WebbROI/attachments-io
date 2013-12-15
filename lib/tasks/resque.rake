require 'resque/tasks'

namespace :resque do
  task :setup do
    require 'resque'

    ENV['QUEUE'] ||= '*'
    Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
  end
end