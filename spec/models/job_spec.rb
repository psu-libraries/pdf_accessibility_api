# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Job do
  describe 'table' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:uuid).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:source_url).of_type(:text).with_options(null: false) }
    it { is_expected.to have_db_column(:status).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:api_user_id).of_type(:integer) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

    it { is_expected.to have_db_index(:api_user_id) }
    it { is_expected.to have_db_index(:uuid) }
  end

  describe 'factories' do
    it { is_expected.to have_valid_factory(:job) }
  end

  describe 'validations' do
    subject(:job) { build(:job) }

    it { is_expected.to validate_inclusion_of(:status).in_array ['processing', 'completed', 'failed'] }

    it 'validates the format of source_url' do
      expect(job).not_to allow_value(nil).for(:source_url)
      expect(job).not_to allow_value('').for(:source_url)
      expect(job).not_to allow_value('invalid').for(:source_url)
      expect(job).not_to allow_value('test.com/invalid').for(:source_url)

      expect(job).to allow_value('https://test.com/file').for(:source_url)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:api_user) }
  end

  describe '.statuses' do
    it 'returns the array of valid status values' do
      expect(described_class.statuses).to eq ['processing', 'completed', 'failed']
    end
  end
end
