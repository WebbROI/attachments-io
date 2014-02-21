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
set :keep_releases, 1

namespace :foreman do
  desc 'Start application'
  task :start do
    on roles(:all) do
      sudo "start #{application}"
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:all) do
      sudo "stop #{application}"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:all) do
      sudo "restart #{application}"
    end
  end

  desc 'Application status'
  task :status do
    on roles(:all) do
      sudo "status #{application}"
    end
  end
end

namespace :deploy do

  desc 'Setup application'
  task :setup do
    on roles(:all) do
      execute "mkdir /var/www/apps/#{application}/run/"
      execute "mkdir /var/www/apps/#{application}/log/"
      execute "mkdir /var/www/apps/#{application}/socket/"
    end
  end

  desc 'Initialize foreman'
  task :foreman_init do
    on roles(:all) do
      foreman_temp = '/var/www/tmp/foreman'
      execute "mkdir -p #{foreman_temp}"
      execute "ln -s #{release_path} #{current_path}"

      within current_path do
        execute "cd #{current_path}"
        execute :bundle, "exec foreman export upstart #{foreman_temp} -a #{application} -u rails -l /var/www/apps/#{application}/log -d #{current_path}"
      end

      sudo "mv #{foreman_temp}/* /etc/init/"
      sudo "rm -r #{foreman_temp}"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "restart #{application}"
    end
  end

  after :publishing, :restart

  after :finishing, 'deploy:cleanup'
  after :finishing, 'deploy:restart'

  after :setup, 'deploy:foreman_init'

  # after :foreman_init, 'foreman:start'

  before :foreman_init, 'rvm:hook'

  before :setup, 'deploy:starting'
  before :setup, 'deploy:updating'
  before :setup, 'bundler:install'
end