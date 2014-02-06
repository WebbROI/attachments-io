require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'syslog/logger'

# Google Drive root folder
IO_ROOT_FOLDER = 'Attachments.IO'

# Google constants
GOOGLE_API_KEY = '606265733457-ttl3kk4hvo6b5b1oep5glovesc2tamuq.apps.googleusercontent.com'
GOOGLE_API_SECRET = 'pq5LlMPapvBw07z62obIsY33'
GOOGLE_APPLICATION_NAME = '@ttachments.io'
GOOGLE_APPLICATION_VERSION = '1.0.0'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

# OpenID Authentication store
require 'openid/store/filesystem'
OpenIdAuthentication.store = OpenID::Store::Filesystem.new('./tmp')

module AttachmentsIO
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    I18n.enforce_available_locales = false
  end
end
