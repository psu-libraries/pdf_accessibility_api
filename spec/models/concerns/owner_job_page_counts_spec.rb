# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OwnerJobPageCounts do
  include ActiveSupport::Testing::TimeHelpers

  let(:now) { Time.zone.parse('2026-02-23 12:00:00') }

  describe '#total_pages_processed_last_24_hours' do
    it 'sums page_count for jobs created in the last 24 hours (APIUser)' do
      travel_to(now)

      api_user = create(:api_user)
      create(:pdf_job, owner: api_user, page_count: 3, created_at: 2.hours.ago)
      create(:pdf_job, owner: api_user, page_count: 5, created_at: 26.hours.ago)
      create(:pdf_job, owner: api_user, page_count: nil, created_at: 1.hour.ago)

      expect(api_user.total_pages_processed_last_24_hours).to eq(3)
    end
  end
end
