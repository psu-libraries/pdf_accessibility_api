# frozen_string_literal: true

class AddIndexOnJobsUuid < ActiveRecord::Migration[7.2]
  def change
    add_index :jobs, :uuid
  end
end
