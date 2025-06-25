# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :jobs do |t|
      t.uuid :uuid, null: false
      t.text :source_url, null: false
      t.string :status, null: false
      t.timestamps null: false
    end
  end
end
