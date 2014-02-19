# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'attachments.io'
set :repo_url, 'git@github.com:WebbROI/attachments-io.git'
set :default_stage, :production
set :rvm_type, :system

role :web, %w{deploy@162.243.44.145}
role :app, %w{deploy@162.243.44.145}
role :db, %w{deploy@162.243.44.145}
server '162.243.44.145', user: 'deploy', roles: %w{web app db}

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
set :default_env, { path: '/opt/ruby/bin:$PATH',
                    rvm_bin_path: '~/.rvm/bin' }

# Default value for keep_releases is 5
set :keep_releases, 1

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
