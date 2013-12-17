class ChangeDefaultValuesForSyncs < ActiveRecord::Migration
  def change
    change_column_default :user_synchronizations, :email_count, 0
    change_column_default :user_synchronizations, :email_parsed, 0
  end
end
