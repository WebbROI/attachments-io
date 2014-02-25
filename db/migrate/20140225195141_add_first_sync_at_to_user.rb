class AddFirstSyncAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_sync_at, :integer, default: nil, null: true
  end
end
