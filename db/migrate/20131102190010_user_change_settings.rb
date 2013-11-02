class UserChangeSettings < ActiveRecord::Migration
  def change
    remove_column :user_settings, :subject_folder

    add_column :user_settings, :subject_in_filename, :boolean, default: false
  end
end
