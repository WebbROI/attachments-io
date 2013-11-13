class MoreInfoForFile < ActiveRecord::Migration
  def change
    add_column :user_synchronization_files, :subject, :string, null: true, default: nil

    add_column :user_synchronization_files, :receipt_date, :integer, null: true, default: nil
    add_column :user_synchronization_files, :send_date, :integer, null: true, default: nil

    add_column :user_synchronization_files, :from, :string, null: true, default: nil
    add_column :user_synchronization_files, :to, :string, null: true, default: nil
  end
end
