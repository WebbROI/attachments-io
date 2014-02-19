set :stage, :production
set :branch, 'master'
set :deploy_to, '/home/rails'

# Bundler
set :bundle_gemfile, -> { release_path.join('Gemfile') }
set :bundle_dir, -> { shared_path.join('bundle') }
set :bundle_flags, '--deployment --quiet'
set :bundle_without, %w{development test}.join(' ')
set :bundle_binstubs, -> { shared_path.join('bin') }
set :bundle_roles, :all
set :bundle_bins, %w(gem rake rails)
