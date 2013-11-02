class RemoveFilenameFormatFromUserSettings < ActiveRecord::Migration
  def change
    remove_column :user_settings, :filename_format
  end
end
