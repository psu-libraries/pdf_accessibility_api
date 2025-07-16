# frozen_string_literal: true

class CreateGUIUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :gui_users do |t|
      t.string :email
      t.timestamps null: false
    end

    change_table :jobs, bulk: true do
      remove_reference :jobs, :api_user, foreign_key: true
      add_reference :jobs, :owner, polymorphic: true, null: false, index: true
    end
  end
end
