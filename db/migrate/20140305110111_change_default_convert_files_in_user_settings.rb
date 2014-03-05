class ChangeDefaultConvertFilesInUserSettings < ActiveRecord::Migration
  def change
    change_column_default :user_settings, :convert_files, false
  end
end
