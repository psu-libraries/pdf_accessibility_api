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
end
