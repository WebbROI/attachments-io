class ChangeDateFormatInTokens < ActiveRecord::Migration
  def change
    change_column :tokens, :expires_at, :timestamp
  end
end
