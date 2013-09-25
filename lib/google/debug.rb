module Google
  class Debug

    def self.access_token
      oauth_consumer = OAuth::Consumer.new(GOOGLE_APP_ID, GOOGLE_APP_SECRET)
      access_token = OAuth::AccessToken.new(oauth_consumer)

      access_token
    end

  end
end