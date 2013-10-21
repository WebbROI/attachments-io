class AddFilenameFormatToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :filename_format, :string, default: nil, null: true
  end
end
