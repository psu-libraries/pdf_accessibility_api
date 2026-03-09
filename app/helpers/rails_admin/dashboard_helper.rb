# frozen_string_literal: true

module RailsAdmin
  module DashboardHelper
    def rails_admin_total_pages_processed
      Job.sum(:page_count)
    end

    def rails_admin_pages_processed_today
      Job.where(created_at: Time.zone.now.beginning_of_day..).sum(:page_count)
    end

    def rails_admin_processing_jobs_count
      Job.where(status: 'processing').count
    end

    def rails_admin_sidekiq_dead_set_size
      Sidekiq::DeadSet.new.size
    end
  end
end
