class AddEmailsCountToUserSynchronizations < ActiveRecord::Migration
  def change
    add_column :user_synchronizations, :email_count, :integer, null: true, default: nil
  end
end
