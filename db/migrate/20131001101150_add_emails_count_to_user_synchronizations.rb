class AddEmailsCountToUserSynchronizations < ActiveRecord::Migration
  def change
    create_table :user_synchronizations
    add_column :user_synchronizations, :email_count, :integer, null: true, default: nil
  end
end
