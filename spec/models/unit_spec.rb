# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Unit do
  describe 'table' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:daily_page_limit).of_type(:integer) }
    it { is_expected.to have_db_column(:overall_page_limit).of_type(:integer) }
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
end
