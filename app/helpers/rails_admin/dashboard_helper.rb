# frozen_string_literal: true

module RailsAdmin
  module DashboardHelper
    def total_pdf_pages_processed
      Job.where(type: 'PdfJob').sum(:page_count)
    end

    def pdf_pages_processed_today
      Job.where(type: 'PdfJob', created_at: Time.zone.now.beginning_of_day..).sum(:page_count)
    end

    def pdf_processing_jobs_count
      Job.where(type: 'PdfJob', status: 'processing').count
    end

    def sidekiq_dead_set_size
      Sidekiq::DeadSet.new.size
    end
  end
end
