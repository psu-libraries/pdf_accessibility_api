# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemediationStatusNotificationJob do
  describe '#perform' do
    it 'returns nil' do
      expect(described_class.perform_now('abc123')).to be_nil
    end
  end
end
