# frozen_string_literal: true

class RenameOutputObjectKeyToObjectKeyInJobs < ActiveRecord::Migration[7.2]
  def change
    rename_column :jobs, :output_object_key, :object_key
  end
end
