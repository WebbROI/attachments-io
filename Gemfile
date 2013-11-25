ruby '2.0.0'
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Development gems
group :development do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Better errors
  gem 'better_errors'
  gem 'binding_of_caller'
end

# Production gems
group :production do
  # Use PostrgreSQL for production
  gem 'pg', group: :production

  # For Heroku assets manager
  gem 'rails_12factor', group: :production
end

# Profiler
gem 'rack-mini-profiler'

# Admin-panel
gem 'activeadmin', github: 'gregbell/active_admin'

# Authentication
gem 'authlogic', '~> 3.3.0'

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
gem 'sass-rails', '~> 4.0.0'
gem 'anjlab-bootstrap-rails', '~> 3.0.2.0', :require => 'bootstrap-rails'

# Use Semantic-UI
# gem 'therubyracer', platforms: :ruby # or any other runtime
# gem 'less-rails'

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
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
