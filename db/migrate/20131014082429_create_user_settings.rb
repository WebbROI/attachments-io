class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.integer :user_id
      t.boolean :subject_folder
      t.boolean :convert_files
    end
  end
end
