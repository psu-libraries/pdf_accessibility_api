# frozen_string_literal: true

class AddOutputMetadataColumnsToJobs < ActiveRecord::Migration[7.2]
  def change
    change_table :jobs, bulk: true do
      add_column :jobs, :finished_at, :datetime
      add_column :jobs, :output_url, :text
      add_column :jobs, :output_object_key, :text
      add_column :jobs, :processing_error_message, :text
    end
  end
end
