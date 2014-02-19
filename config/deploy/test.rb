set :stage, :test
set :branch, 'test'
set :deploy_to, '/home/rails-test'

# Bundler
set :bundle_gemfile, -> { release_path.join('Gemfile') }
set :bundle_dir, -> { shared_path.join('bundle') }
set :bundle_flags, '--deployment --quiet'
set :bundle_without, %w{production development}.join(' ')
set :bundle_binstubs, -> { shared_path.join('bin') }
set :bundle_roles, :all
set :bundle_bins, %w(gem rake rails)