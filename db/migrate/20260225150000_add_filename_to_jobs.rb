# frozen_string_literal: true

class AddFilenameToJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :jobs, :filename, :string
  end
end
