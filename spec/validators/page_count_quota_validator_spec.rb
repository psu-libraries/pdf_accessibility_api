# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PageCountQuotaValidator do
  describe '.validate!' do
    let(:unit) { create(:unit, overall_page_limit: 10, user_daily_page_limit: 100) }
    let(:api_user) { create(:api_user, unit: unit) }

    before do
      create(:pdf_job, owner: api_user, page_count: 7)
    end

    context 'when page_count is within quota' do
      it 'returns true' do
        expect(described_class.validate!(owner: api_user, page_count: 3)).to be(true)
      end
    end

    context "when page_count exceeds unit's total quota" do
      it 'raises QuotaExceededError' do
        expect {
          described_class.validate!(owner: api_user, page_count: 4)
        }.to raise_error(
          PageCountQuotaValidator::QuotaExceededError,
          "page_count exceeds the unit's overall page limit of 10"
        )
      end
    end

    context "when page_count exceeds user's daily quota" do
      before do
        unit.update(user_daily_page_limit: 9)
      end

      it 'raises QuotaExceededError' do
        expect {
          described_class.validate!(owner: api_user, page_count: 3)
        }.to raise_error(
          PageCountQuotaValidator::QuotaExceededError,
          "page_count exceeds the user's daily page limit of 9"
        )
      end
    end

    context 'when owner has no unit' do
      it 'raises MissingUnitError' do
        unitless_user = create(:api_user, unit: nil)

        expect {
          described_class.validate!(owner: unitless_user, page_count: 1)
        }.to raise_error(PageCountQuotaValidator::MissingUnitError)
      end
    end

    context 'when page_count is not a valid integer' do
      it 'raises InvalidPageCountError' do
        expect {
          described_class.validate!(owner: api_user, page_count: 0)
        }.to raise_error(PageCountQuotaValidator::InvalidPageCountError)

        expect {
          described_class.validate!(owner: api_user, page_count: 'nope')
        }.to raise_error(PageCountQuotaValidator::InvalidPageCountError)
      end
    end
  end
end
