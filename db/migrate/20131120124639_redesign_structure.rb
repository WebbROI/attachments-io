class RedesignStructure < ActiveRecord::Migration
  def change
    # remove all users & info about they
    User.destroy_all

    # add last_sync to user
    add_column :users, :last_sync, :integer, default: nil, null: true

    # drop sync table
    drop_table :user_synchronizations

    # redesign files table
    rename_table :user_synchronization_files, :user_email_files
    rename_column :user_email_files, :user_synchronization_id, :user_email_id
    remove_columns :user_email_files, :email_date, :from, :label, :subject, :to
  end
end
