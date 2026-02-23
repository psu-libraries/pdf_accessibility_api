# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PageCountWithinQuotaValidator do
  describe '.validate!' do
    let(:unit) { create(:unit, overall_page_limit: 10) }
    let(:api_user) { create(:api_user, unit: unit) }

    before do
      create(:pdf_job, owner: api_user, page_count: 7)
    end

    it 'allows page_count when within remaining quota' do
      expect(described_class.validate!(owner: api_user, page_count: 3)).to be(true)
    end

    it 'raises when page_count would exceed quota' do
      expect {
        described_class.validate!(owner: api_user, page_count: 4)
      }.to raise_error(PageCountWithinQuotaValidator::QuotaExceededError)
    end

    it 'raises when owner has no unit' do
      unitless_user = create(:api_user, unit: nil)

      expect {
        described_class.validate!(owner: unitless_user, page_count: 1)
      }.to raise_error(PageCountWithinQuotaValidator::MissingUnitError)
    end

    it 'raises when page_count is not a positive integer' do
      expect {
        described_class.validate!(owner: api_user, page_count: 0)
      }.to raise_error(PageCountWithinQuotaValidator::InvalidPageCountError)

      expect {
        described_class.validate!(owner: api_user, page_count: 'nope')
      }.to raise_error(PageCountWithinQuotaValidator::InvalidPageCountError)
    end
  end
end
