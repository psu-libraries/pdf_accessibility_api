class AddTypeToJob < ActiveRecord::Migration[7.2]
  def change
    add_column :jobs, :type, :string
    add_column :jobs, :prompt, :text
    add_column :jobs, :llm_model, :string
    add_column :jobs, :alt_text, :text
  end
end
