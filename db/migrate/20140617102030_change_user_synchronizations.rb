class ChangeUserSynchronizations < ActiveRecord::Migration
  def up
  	rename_table :user_synchronizations, :synchronizations
    remove_column :synchronizations, :previous_status
  end

  def down
  	rename_table :synchronizations, :user_synchronizations
    add_column :user_synchronizations, :previous_status, :integer, default: 0
  end
end
