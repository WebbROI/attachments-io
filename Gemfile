source 'https://rubygems.org'
ruby '2.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Development gems
group :development do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

# Production gems
group :production do
  # Use PostrgreSQL for production
  gem 'pg', group: :production

  # For Heroku
  gem 'rails_12factor', group: :production
end

# Authentication
gem 'authlogic', '~> 3.3.0'

# Google OAuth2
gem 'oauth'
gem 'omniauth-google-oauth2'

# SAML for Google SSO
gem 'ruby-openid', '~> 2.3.0'
#gem 'rack-openid', '~> 1.3.1'
#gem 'omniauth-openid', '~> 1.0.1'
gem 'open_id_authentication', '~> 1.2.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Twitter Bootstrap
gem 'bootstrap-sass', '~> 2.3.2.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

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
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
