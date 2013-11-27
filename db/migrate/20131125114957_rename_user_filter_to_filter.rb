class RenameUserFilterToFilter < ActiveRecord::Migration
  def change
    rename_table :user_filters, :filters
  end
end
