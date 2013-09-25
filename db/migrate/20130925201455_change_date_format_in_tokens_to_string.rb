class ChangeDateFormatInTokensToString < ActiveRecord::Migration
  def change
    change_column :tokens, :expires_at, :string
  end
end
