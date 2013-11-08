class AddErrorMessageToUserSynchronizations < ActiveRecord::Migration
  def change
    add_column :user_synchronizations, :error_message, :string
  end
end
