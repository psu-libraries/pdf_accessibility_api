# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GUIUser do
  describe 'table' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'factories' do
    it { is_expected.to have_valid_factory(:gui_user) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:jobs).dependent(:restrict_with_exception) }
  end
end
