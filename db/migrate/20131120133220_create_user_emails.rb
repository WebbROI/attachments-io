class CreateUserEmails < ActiveRecord::Migration
  def change
    create_table :user_emails, force: true do |t|
      t.integer :user_id
      t.string :label
      t.string :subject
      t.string :from
      t.string :to
      t.integer :date
    end
  end
end
