# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq/testing'
require 'okcomputer'
require 'health_checks'

RSpec.describe HealthChecks::QueueDeadSetCheck do
  describe '#check' do
    it 'passes when deadset empty' do
      deadset = instance_double(Sidekiq::DeadSet, size: 0)
      allow(Sidekiq::DeadSet).to receive(:new).and_return(deadset)

      hc = described_class.new
      hc.check

      expect(hc.failure_occurred).to be_nil
    end

    it 'fails when deadset has jobs' do
      deadset = instance_double(Sidekiq::DeadSet, size: 1)
      allow(Sidekiq::DeadSet).to receive(:new).and_return(deadset)

      hc = described_class.new
      hc.check

      expect(hc.failure_occurred).to be true
      expect(hc.message).to eq 'There are 1 messages in the DeadSet Queue'
    end
  end
end
