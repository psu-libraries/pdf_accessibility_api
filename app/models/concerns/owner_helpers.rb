# frozen_string_literal: true

module OwnerHelpers
  def total_pages_processed_last_24_hours
    jobs
      .where(created_at: 24.hours.ago..)
      .where(status: ['completed', 'processing'])
      .where.not(page_count: nil)
      .sum(:page_count)
  end
end
