# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemediationJob do
  describe '#perform' do
    it 'returns truthy' do
      expect(described_class.perform_now('abc123')).to be_truthy
    end
  end
end
