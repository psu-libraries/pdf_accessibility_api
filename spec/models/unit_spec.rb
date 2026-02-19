# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Unit do
  describe 'table' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:daily_page_limit).of_type(:integer).with_options(null: false, default: 30) }
    it { is_expected.to have_db_column(:overall_page_limit).of_type(:integer).with_options(null: false, default: 25000) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'factories' do
    it { is_expected.to have_valid_factory(:unit) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:api_users).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:gui_users).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:daily_page_limit) }
    it { is_expected.to validate_presence_of(:overall_page_limit) }
  end

  describe '#total_pages_processed' do
    let(:unit) { create(:unit) }

    it 'sums the page_count of jobs for API users in the unit' do
      api_user1 = create(:api_user, unit: unit)
      api_user2 = create(:api_user, unit: unit)

      create(:pdf_job, owner: api_user1, page_count: 3)
      create(:pdf_job, owner: api_user1, page_count: 2)
      create(:pdf_job, owner: api_user2, page_count: 5)

      other_unit = create(:unit)
      other_user = create(:api_user, unit: other_unit)
      create(:pdf_job, owner: other_user, page_count: 100)

      expect(unit.total_pages_processed).to eq(10)
    end

    it 'returns 0 when there are no jobs for API users in the unit' do
      create(:api_user, unit: unit)

      expect(unit.total_pages_processed).to eq(0)
    end
  end
end
