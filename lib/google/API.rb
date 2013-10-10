require 'google/api_client'

module Google
  class API

    FOLDER_MIME = 'application/vnd.google-apps.folder'

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

    def load_api(name, version = nil)
      return @apis[name] unless @apis[name].nil?
      @apis[name] = @client.discovered_api(name, version)
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

    def load_files
      execute(
          api_method: load_api('drive', 'v2').files.list,
          parameters: {
              q: "(trashed = false) and (mimeType != 'application/vnd.google-apps.document') and (mimeType != 'application/vnd.google-apps.spreadsheet') and (mimeType != 'application/vnd.google-apps.form')",
              fields: 'items(fileSize,id,mimeType,title,alternateLink,parents(id,isRoot))'
          }
      )
    end

    def upload_file(params)
      puts params.inspect

      file = load_api('drive', 'v2').files.insert.request_schema.new(
          'title' => params[:title],
          'description' => params[:description],
          'mimeType' => params[:mime_type],
          'parents' => ['id' => params[:parent_id]]
      )

      media = Google::APIClient::UploadIO.new(params[:path], params[:mime_type], params[:title])

      execute(
          api_method: load_api('drive', 'v2').files.insert,
          body_object: file,
          media: media,
          parameters: {
              'uploadType' => 'multipart',
              'alt' => 'json',
              'visibility' => 'PRIVATE'
          }
      )
    end

    def create_folder(params)
      parameters = { title: params[:title], mimeType: FOLDER_MIME }

      if params[:parent_id]
        parameters[:parents] = [ id: params[:parent_id]]
      end

      schema = load_api('drive', 'v2').files.insert.request_schema.new(parameters)

      execute(
          api_method: load_api('drive', 'v2').files.insert,
          body_object: schema,
          parameters: {
              visibility: 'PRIVATE'
          }
      )
    end
  end
end