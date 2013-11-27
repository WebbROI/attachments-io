class RenameUserEmailFileToEmailFile < ActiveRecord::Migration
  def change
    rename_table :user_email_files, :email_files
  end
end
