# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImageJob do
  let(:job) { build(:image_job) }

  describe 'factories' do
    it { is_expected.to have_valid_factory(:image_job) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:owner) }
  end
end
