require 'google/api_client'

module Google
  class API

    FOLDER_MIME = 'application/vnd.google-apps.folder'

    def initialize(params = nil)
      @client = Google::APIClient.new(
          application_name: Rails.application.secrets.google_application_name,
          application_version: Rails.application.secrets.google_application_version
      )
      @client.authorization.client_id = Rails.application.secrets.google_api_key
      @client.authorization.client_secret = Rails.application.secrets.google_api_secret

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

      if need_update_token?
        @client.authorization.fetch_access_token!

        return true
      end

      false
    end

    def need_update_token?
      !!@client.authorization.refresh_token && (@client.authorization.issued_at + @client.authorization.expires_in).to_i < Time.now.to_i
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
      if need_update_token?
        update_token!
      end

      @client.execute(options)
    end

    def load_files(params = {})
      query = "(trashed = false) and (mimeType != 'application/vnd.google-apps.document') and (mimeType != 'application/vnd.google-apps.spreadsheet') and (mimeType != 'application/vnd.google-apps.form') and (mimeType != 'application/vnd.google-apps.drawing')"

      if params[:title]
        query += " and (title = '#{params[:title]}')"
      end

      if params[:parent_id]
        query += " and ('#{params[:parent_id]}' in parents)"
      end

      if params[:is_root]
        query += " and ('root' in parents)"
      end

      if params[:is_folder].is_a?(true.class)
        query += " and (mimeType = 'application/vnd.google-apps.folder')"
      elsif params[:is_folder].is_a?(false.class)
        query += " and (mimeType != 'application/vnd.google-apps.folder')"
      end

      execute(
          api_method: load_api('drive', 'v2').files.list,
          parameters: {
              q: query,
              fields: 'items(fileSize,id,mimeType,title,alternateLink,parents(id,isRoot))'
          }
      )
    end

    def upload_file(params)
      if !!params[:convert]
        convert = 'true'
      else
        convert = 'false'
      end

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
              'convert' => convert,
              'uploadType' => 'multipart',
              'alt' => 'json',
              'visibility' => 'PRIVATE'
          }
      )
    end

    def delete_file(file_id)
      execute(
          api_method: load_api('drive', 'v2').files.delete,
          parameters: { 'fileId' => file_id }
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