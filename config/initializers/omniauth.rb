Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GOOGLE_API_KEY, GOOGLE_API_SECRET,
           {
               name: :google,
               scope: 'userinfo.email, userinfo.profile, plus.me, https://mail.google.com/',
               access_type: 'offline'
           }
end