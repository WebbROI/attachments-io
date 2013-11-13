class ChangeFileInfo < ActiveRecord::Migration
  def change
    rename_column :user_synchronization_files, :created_at, :uploaded_at
    remove_column :user_synchronization_files, :updated_at

    remove_column :user_synchronization_files, :receipt_date
    remove_column :user_synchronization_files, :send_date

    add_column :user_synchronization_files, :email_date, :integer
  end
end
