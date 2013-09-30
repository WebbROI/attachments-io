class AddIssuedAtAndExpiresInToUserTokens < ActiveRecord::Migration
  def change
    remove_column :user_tokens, :expires_at

    add_column :user_tokens, :issued_at, :integer
    add_column :user_tokens, :expires_in, :integer
  end
end
