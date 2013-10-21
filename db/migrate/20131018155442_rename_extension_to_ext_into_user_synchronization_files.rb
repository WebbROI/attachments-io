class RenameExtensionToExtIntoUserSynchronizationFiles < ActiveRecord::Migration
  def change
    rename_column :user_synchronization_files, :extension, :ext
  end
end
