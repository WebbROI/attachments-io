class RemoveActiveAdmin < ActiveRecord::Migration
  def change
    drop_table :admin_users if table_exists? :admin_users
    drop_table :active_admin_comments if table_exists? :active_admin_comments
  end
end
