class RenameUserEmailId < ActiveRecord::Migration
  def change
    rename_column :user_email_files, :user_email_id, :email_id
  end
end
