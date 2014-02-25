class AddStartedAtToUserSynchronizations < ActiveRecord::Migration
  def change
    add_column :user_synchronizations, :started_at, :integer, default: nil, null: true
  end
end
