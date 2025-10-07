# frozen_string_literal: true

class AddTypeToJob < ActiveRecord::Migration[7.2]
  def change
    change_table :jobs, bulk: true do |t|
      t.string :type
      t.text :prompt
      t.string :llm_model
      t.text :alt_text
    end
  end
end
