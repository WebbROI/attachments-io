require 'google/api_client'

module Google
  class API

    def initialize(params = nil)
      @client = Google::APIClient.new(
          application_name: GOOGLE_APPLICATION_NAME,
          application_version: GOOGLE_APPLICATION_VERSION
      )
      @client.authorization.client_id = GOOGLE_API_KEY
      @client.authorization.client_secret = GOOGLE_API_SECRET

      #@client.authorization.scope = %w[
      #    https://www.googleapis.com/auth/userinfo.email
      #    https://www.googleapis.com/auth/userinfo.profile
      #    https://www.googleapis.com/auth/plus.me
      #    https://mail.google.com/
      #]

      @apis = Hash.new

      if params[:tokens]
        @client.authorization.update_token!(params[:tokens])
      end
    end

    def load_api(name)
      return @apis[name] if @apis[name]
      @apis[name] = @client.discovered_api(name)
      @apis[name]
    end

    def update_token!(tokens = nil)
      if tokens
        @client.authorization.update_token!(tokens)
      end

      if !!@client.authorization.refresh_token && (@client.authorization.issued_at + @client.authorization.expires_in).to_i < Time.now.to_i
        @client.authorization.fetch_access_token!

        return true
      end

      false
    end

    def tokens
      {
          access_token: @client.authorization.access_token,
          refresh_token: @client.authorization.refresh_token,
          issued_at: @client.authorization.issued_at,
          expires_in: @client.authorization.expires_in
      }
    end

    def execute(options = nil)
      @client.execute(options)
    end
  end
end