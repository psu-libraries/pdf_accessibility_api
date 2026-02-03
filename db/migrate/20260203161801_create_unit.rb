# frozen_string_literal: true

class CreateUnit < ActiveRecord::Migration[7.2]
  def change
    create_table :units do |t|
      t.string :name
      t.integer :daily_page_limit, null: false, default: 30
      t.integer :overall_page_limit, null: false, default: 25000

      t.timestamps
    end

    add_reference :api_users, :unit, foreign_key: true
    add_reference :gui_users, :unit, foreign_key: true
  end
end
