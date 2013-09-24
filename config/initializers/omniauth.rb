Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem'
  provider :google_apps, store: OpenID::Store::Filesystem.new('./tmp')
  OpenID::Util.logger = OpenID.logger = Rails.logger
end