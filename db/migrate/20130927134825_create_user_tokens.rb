class CreateUserTokens < ActiveRecord::Migration
  def change
    create_table :user_tokens do |t|
      t.string  :user_id
      t.string  :access_token
      t.string  :refresh_token
      t.integer :expires_at
    end
  end
end
