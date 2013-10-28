class CreateUserFilters < ActiveRecord::Migration
  def change
    create_table :user_filters do |t|
      t.integer :user_id

      t.boolean :images_filters
      t.string  :images_extensions
      t.integer :images_min_size
      t.integer :images_max_size

      t.boolean :documents_filters
      t.string  :documents_extensions
      t.integer :documents_min_size
      t.integer :documents_max_size
    end
  end
end
