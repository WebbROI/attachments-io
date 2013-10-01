class CreateUserSynchronizations < ActiveRecord::Migration
  def change
    create_table :user_synchronizations do |t|
      t.integer :user_id
      t.integer :status
      t.integer :started_at
      t.integer :finished_at
      t.integer :file_count
    end
  end
end
