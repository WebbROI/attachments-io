Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem'

  provider :google_apps, store: OpenID::Store::Filesystem.new('./tmp')

  provider :google_oauth2, '613215852608', 'IR0NrvPqgVHXe80XrkRI8n04',
           {
               scope: 'userinfo.email, userinfo.profile, plus.me, https://mail.google.com/',
               prompt: 'select_account',
               access_type: 'offline',
               approval_prompt: 'force'
           }

  OpenID::Util.logger = OpenID.logger = Rails.logger
end