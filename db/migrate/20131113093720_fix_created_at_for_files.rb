class FixCreatedAtForFiles < ActiveRecord::Migration
  def change
    rename_column :user_synchronization_files, :uploaded_at, :created_at
  end
end
