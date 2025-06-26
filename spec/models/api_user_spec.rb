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
    it { is_expected.to have_many(:jobs) }
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
end
