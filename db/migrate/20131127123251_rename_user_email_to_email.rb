class RenameUserEmailToEmail < ActiveRecord::Migration
  def change
    rename_table :user_emails, :emails
  end
end
