# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfJob do
  let(:gui_job) { build(:pdf_job, :gui_user_job) }

  let(:job) { build(:pdf_job) }

  describe 'table' do
    it { is_expected.to delegate_method(:webhook_endpoint).to(:owner) }
    it { is_expected.to delegate_method(:webhook_key).to(:owner) }
  end

  describe 'factories' do
    it { is_expected.to have_valid_factory(:pdf_job) }
  end

  describe 'validations' do
    context 'when the owner is an APIUSer' do
      it 'validates the format of source_url' do
        [nil, '', 'invalid', 'test.com/invalid'].each do |url|
          job.source_url = url
          expect(job).not_to be_valid
        end
        job.source_url = 'https://test.com/file'
        expect(job).to be_valid
      end
    end

    context 'when the owner is a GUIUser' do
      it 'does not validate for source_url' do
        expect(gui_job.source_url).to be_nil
        expect(gui_job).to be_valid
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:owner) }
  end

  describe '#output_url_expired?' do
    let(:job) { described_class.new(output_url_expires_at: expires_at) }

    context 'when output_url_expires_at is nil' do
      let(:expires_at) { nil }

      it 'returns false' do
        expect(job.output_url_expired?).to be(false)
      end
    end

    context 'when output_url_expires_at is in the future' do
      let(:expires_at) { 1.hour.from_now }

      it 'returns false' do
        expect(job.output_url_expired?).to be(false)
      end
    end

    context 'when output_url_expires_at is in the past' do
      let(:expires_at) { 1.hour.ago }

      it 'returns true' do
        expect(job.output_url_expired?).to be(true)
      end
    end
  end
end
