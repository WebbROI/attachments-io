Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '613215852608', 'IR0NrvPqgVHXe80XrkRI8n04',
           {
               name: :google,
               scope: 'userinfo.email, userinfo.profile, plus.me, https://mail.google.com/',
               access_type: 'offline'
           }
end