class AddActiveToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :active, :boolean, default: true
  end
end
