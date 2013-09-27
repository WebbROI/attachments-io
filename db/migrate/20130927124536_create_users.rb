class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, default: '', null: false
      t.string :picture
      t.string :uid

      # Authlogic magic columns
      t.string    :persistence_token, null: false
      t.integer   :login_count,       default: 0, null: false
      t.datetime  :current_login_at
      t.string    :current_login_ip
      t.datetime  :last_login_at
      t.string    :last_login_ip

      t.timestamps
    end
  end
end
