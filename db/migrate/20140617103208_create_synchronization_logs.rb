class CreateSynchronizationLogs < ActiveRecord::Migration
  def up
    create_table :synchronization_logs do |t|
      t.references :user, index: true

      t.integer :status
      t.integer :email_count
      t.integer :file_count

      t.timestamp :started_at
      t.timestamp :finished_at
    end
  end

  def down
    drop_table :synchronization_logs
  end
end
