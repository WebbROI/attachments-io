listen '127.0.0.1:8080'

worker_processes 3
working_directory '/home/rails/current'

user 'rails'

pid '/home/unicorn/pids/unicorn.pid'

stderr_path '/home/unicorn/log/unicorn.log'
stdout_path '/home/unicorn/log/unicorn.log'