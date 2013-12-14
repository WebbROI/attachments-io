class CreateUserSynchronizations < ActiveRecord::Migration
  def change
    create_table :user_synchronization do |t|
      t.integer :user_id
      t.integer :status
      t.integer :email_count
      t.integer :email_parsed
      t.integer :previous_status
    end
  end
end
