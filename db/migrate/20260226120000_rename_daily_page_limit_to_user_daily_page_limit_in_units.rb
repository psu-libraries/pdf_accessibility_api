# frozen_string_literal: true

class RenameDailyPageLimitToUserDailyPageLimitInUnits < ActiveRecord::Migration[7.2]
  def change
    rename_column :units, :daily_page_limit, :user_daily_page_limit
  end
end
