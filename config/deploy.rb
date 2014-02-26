# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'app.attachments.io'
set :repo_url, 'git@github.com:WebbROI/attachments-io.git'
set :rvm_type, :user
set :rvm_ruby_version, '2.1.0'

# role :web, %w{root@162.243.44.145}
# role :app, %w{root@162.243.44.145}
# role :db, %w{root@162.243.44.145}
server '162.243.44.145', user: 'rails', roles: %w{web app db}

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: '/opt/ruby/bin:$PATH' }

# Default value for keep_releases is 5
set :keep_releases, 3