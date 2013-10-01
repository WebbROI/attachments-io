class AddEmailsParsedToUserSynchronizations < ActiveRecord::Migration
  def change
    add_column :user_synchronizations, :email_parsed, :integer, null: true, default: nil
  end
end
