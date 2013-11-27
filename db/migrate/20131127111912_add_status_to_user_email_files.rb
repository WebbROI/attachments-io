class AddStatusToUserEmailFiles < ActiveRecord::Migration
  def change
    add_column :user_email_files, :status, :integer
  end
end
