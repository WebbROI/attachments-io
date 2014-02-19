set :application, '@ttachments.io'
set :repo_url, 'git@github.com:WebbROI/attachments-io.git'
set :pty, true
set :keep_releases, 1
set :scm, :git

task :production do
  set :branch, 'master'
  set :deploy_to, '/home/rails'
end

task :test do
  set :branch, 'test'
  set :deploy_to, '/home/rails-test'
end
