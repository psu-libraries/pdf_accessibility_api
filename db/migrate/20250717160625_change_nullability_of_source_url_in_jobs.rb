class ChangeNullabilityOfSourceUrlInJobs < ActiveRecord::Migration[7.2]
  def change
    change_column_null :jobs, :source_url, true
  end
end
