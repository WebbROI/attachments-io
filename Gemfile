ruby '2.1.0'
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.3'
gem 'bundler'

# Mixed gems
gem 'pg', '0.17.1', group: [:production, :test]
gem 'better_errors', group: [:development, :test]
gem 'binding_of_caller', group: [:development, :test]

# Development gems
group :development do
  gem 'sqlite3'

  # Pum pum puma
  gem 'puma'
end

# Admin-panel
gem 'activeadmin', github: 'gregbell/active_admin'

# Resque & Redis
gem 'resque', require: 'resque/server'
gem 'redis'

# Foreman
gem 'foreman'

# Authentication
gem 'authlogic', github: 'binarylogic/authlogic'

# Google OAuth2
gem 'oauth', '~> 0.4.7'
gem 'omniauth', '~> 1.1.4'
gem 'omniauth-google-oauth2', '~> 0.2.1'
gem 'google-api-client', '~> 0.6.4'
gem 'gmail_xoauth', '~> 0.4.1'

# SAML for Google SSO
gem 'ruby-openid', '~> 2.3.0'
gem 'open_id_authentication', '~> 1.2.0'

# Mail parsing
gem 'mail', '~> 2.5.4'

# Russian transliteration
gem 'russian', '~> 0.6.0'

# MailChimp
gem 'gibbon', '~> 1.0.4'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.1'
gem 'anjlab-bootstrap-rails', '~> 3.0.3.0', require: 'bootstrap-rails'

# Retina images
gem 'retina_tag'

# Twitter Bootstrap
gem 'bootstrap-sass', '~> 2.3.2.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
gem 'unicorn'
gem 'unicorn-rails'

# Use debugger
# gem 'debugger', group: [:development, :test]

# Log system
gem 'SyslogLogger'