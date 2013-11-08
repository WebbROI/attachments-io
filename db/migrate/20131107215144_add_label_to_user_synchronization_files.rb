class AddLabelToUserSynchronizationFiles < ActiveRecord::Migration
  def change
    add_column :user_synchronization_files, :label, :string
  end
end
