class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.integer :user_id
      t.string :token
      t.string :refresh_token
      t.datetime :expires_at
    end
  end
end
