# frozen_string_literal: true

class AddOutputUrlExpiresAtToJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :jobs, :output_url_expires_at, :datetime, null: true
  end
end
