class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_admin, :boolean, default: false

    User.find_by_email('andrew@webbroi.com').try(:update_attribute, :is_admin, true)
  end
end
