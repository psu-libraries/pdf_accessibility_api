# frozen_string_literal: true

require 'rails_helper'

RSpec.describe APIUser do
  describe 'table' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:api_key).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:webhook_key).of_type(:string) }
    it { is_expected.to have_db_column(:webhook_endpoint).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

    it { is_expected.to have_db_index(:api_key).unique(true) }
    it { is_expected.to have_db_index(:webhook_key).unique(true) }
  end

  describe 'factories' do
    it { is_expected.to have_valid_factory(:api_user) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:jobs).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    subject(:user) { described_class.new }

    it { is_expected.to validate_presence_of(:webhook_endpoint) }

    it 'validates the format of webhook_endpoint' do
      expect(user).not_to allow_value('').for(:webhook_endpoint)
      expect(user).not_to allow_value('invalid').for(:webhook_endpoint)
      expect(user).not_to allow_value('test.com/invalid').for(:webhook_endpoint)
      expect(user).not_to allow_value('http://test.com/webhook').for(:webhook_endpoint)

      expect(user).to allow_value('https://test.com/webhook').for(:webhook_endpoint)
    end
  end

  describe 'creating a new API user' do
    let(:api_user) { build(:api_user, api_key: nil, webhook_key: nil) }

    it 'generates an API key' do
      api_user.save!
      expect(api_user.api_key.length).to eq 104
      expect(api_user.api_key[0..7]).to eq 'api_key_'
    end

    it 'generates a webhook key' do
      api_user.save!
      expect(api_user.webhook_key.length).to eq 103
      expect(api_user.webhook_key[0..6]).to eq 'wh_key_'
    end
  end

  describe '#total_pages_processed_today' do
    let(:api_user) { create(:api_user) }

    it 'sums the page_count of jobs created in the last 24 hours' do
      create(:pdf_job, owner: api_user, page_count: 3, created_at: 2.hours.ago)
      create(:pdf_job, owner: api_user, page_count: 5, created_at: 23.hours.ago)

      create(:pdf_job, owner: api_user, page_count: 100, created_at: 25.hours.ago)

      expect(api_user.total_pages_processed_today).to eq(8)
    end

    it 'returns 0 when there are no recent jobs' do
      create(:pdf_job, owner: api_user, page_count: 10, created_at: 25.hours.ago)

      expect(api_user.total_pages_processed_today).to eq(0)
    end
  end
end
