class CreateUserSynchronizationFiles < ActiveRecord::Migration
  def change
    create_table :user_synchronization_files do |t|
      t.integer :user_synchronization_id
      t.string :filename
      t.integer :size
      t.string :link

      t.timestamps
    end
  end
end
