class AddLoggingToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :logging, :boolean, default: false
  end
end
