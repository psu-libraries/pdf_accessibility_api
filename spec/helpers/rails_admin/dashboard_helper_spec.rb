# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RailsAdmin::DashboardHelper do
  describe '#total_pdf_pages_processed' do
    it 'returns the sum of page_count across all PDF jobs' do
      create(:pdf_job, status: 'completed', page_count: 10)
      create(:image_job, status: 'completed', page_count: nil)
      create(:pdf_job, status: 'completed', page_count: 5)

      expect(helper.total_pdf_pages_processed).to eq(15)
    end
  end

  describe '#pdf_pages_processed_today' do
    it 'returns the sum of page_count for PDF jobs created today' do
      today_job = create(:pdf_job, status: 'completed', page_count: 12)
      old_job = create(:pdf_job, status: 'completed', page_count: 30)

      today_job.update(created_at: Time.zone.now.beginning_of_day + 1.hour)
      old_job.update(created_at: 2.days.ago)

      expect(helper.pdf_pages_processed_today).to eq(12)
    end
  end

  describe '#pdf_processing_jobs_count' do
    it 'returns the number of PDF jobs with processing status' do
      create(:pdf_job, status: 'processing')
      create(:image_job, status: 'processing')
      create(:pdf_job, status: 'completed')

      expect(helper.pdf_processing_jobs_count).to eq(1)
    end
  end

  describe '#sidekiq_dead_set_size' do
    it 'returns the dead set size from Sidekiq' do
      dead_set = instance_double(Sidekiq::DeadSet, size: 7)
      allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_set)

      expect(helper.sidekiq_dead_set_size).to eq(7)
    end
  end
end
