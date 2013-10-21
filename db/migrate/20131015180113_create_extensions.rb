class CreateExtensions < ActiveRecord::Migration
  require 'csv'

  def change
    create_table :extensions do |t|
      t.string :extension
      t.string :file_type
      t.string :folder
      t.string :sub_folder
    end

    CSV.foreach("#{Rails.root}/db/migrate/extensions.csv", headers: true) do |row|
      Extension.create!(row.to_hash)
    end
  end
end
