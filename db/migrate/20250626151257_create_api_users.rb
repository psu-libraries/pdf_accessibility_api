class CreateAPIUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :api_users do |t|
      t.string :name
      t.string :email
      t.string :api_key, null: false
      t.string :webhook_key
      t.text :webhook_endpoint
      t.timestamps null: false
    end

    add_index :api_users, :api_key, unique: true
    add_index :api_users, :webhook_key, unique: true

    add_column :jobs, :api_user_id, :bigint, null: false
    add_index :jobs, :api_user_id
    add_foreign_key :jobs, :api_users
  end
end
