worker_processes 3
working_directory '/home/rails/current'

user 'root'

pid '/home/rails/current/tmp/pids/unicorn.pid'
listen '/home/rails/current/tmp//sockets/unicorn.sock'

stderr_path '/home/unicorn/log/unicorn.log'
stdout_path '/home/unicorn/log/unicorn.log'

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
end