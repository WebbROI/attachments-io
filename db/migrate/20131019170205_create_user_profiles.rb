class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.integer :user_id
      t.string :plus
      t.string :twitter
      t.string :facebook
      t.string :gender
      t.string :organization
      t.string :location

      t.timestamps
    end
  end
end
