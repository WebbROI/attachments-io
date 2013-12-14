class RenameUserSynchronizations < ActiveRecord::Migration
  def change
    rename_table :user_synchronization, :user_synchronizations
  end
end
