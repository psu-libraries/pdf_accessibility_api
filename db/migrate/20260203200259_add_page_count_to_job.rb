class AddPageCountToJob < ActiveRecord::Migration[7.2]
  def change
    add_column :jobs, :page_count, :integer, null: true
  end
end
