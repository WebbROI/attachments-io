Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.on_failure = SigninController.action(:error)

  provider :google_oauth2, Rails.application.secrets.google_api_key, Rails.application.secrets.google_api_secret,
           {
               name: :google,
               scope: 'userinfo.email, userinfo.profile, plus.me, https://www.googleapis.com/auth/drive, https://mail.google.com/',
               access_type: 'offline',
           }
end