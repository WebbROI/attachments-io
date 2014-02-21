application = 'app.attachments.io'

set :stage, :production
set :branch, 'master'
set :deploy_to, '/var/www/apps/app.attachments.io'
set :rails_env, 'production'

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
