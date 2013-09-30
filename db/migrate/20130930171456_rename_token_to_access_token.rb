class RenameTokenToAccessToken < ActiveRecord::Migration
  def change
    rename_column :user_tokens, :token, :access_token
  end
end
