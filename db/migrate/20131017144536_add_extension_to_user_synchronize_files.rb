class AddExtensionToUserSynchronizeFiles < ActiveRecord::Migration
  def change
    add_column :user_synchronization_files, :extension, :string
  end
end
