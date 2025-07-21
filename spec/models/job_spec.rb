# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Job do
  subject(:job) { build(:job) }
  subject(:gui_job) {build(:job, :gui_user_job)}
  describe 'table' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:uuid).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:source_url).of_type(:text) }
    it { is_expected.to have_db_column(:status).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:owner_id) }
    it { is_expected.to have_db_column(:owner_type) }
    it { is_expected.to have_db_column(:finished_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:output_url).of_type(:text) }
    it { is_expected.to have_db_column(:output_object_key).of_type(:text) }
    it { is_expected.to have_db_column(:processing_error_message).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

    it { is_expected.to have_db_index([:owner_type, :owner_id]) }
    it { is_expected.to have_db_index(:uuid) }
    it { is_expected.to delegate_method(:webhook_endpoint).to(:owner) }
    it { is_expected.to delegate_method(:webhook_key).to(:owner) }
  end

  describe 'factories' do
    it { is_expected.to have_valid_factory(:job) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:status).in_array ['processing', 'completed', 'failed'] }

    context 'when there is no file attached' do
      it 'validates the format of source_url' do
        expect(job.file.attached?).to eq(false)
        [nil, '', 'invalid', 'test.com/invalid'].each do |url|
          job.source_url = url
          expect(job).not_to be_valid
        end
        job.source_url = 'https://test.com/file'
        expect(job).to be_valid
      end
    end

    context 'when the source_url is nil' do
      it 'validates the presence of attached file' do
        expect(gui_job.source_url).to be_nil
        expect(gui_job.file.attached?).to eq(true)
        expect(gui_job.valid?).to eq(true)

        gui_job.file.purge
        expect(gui_job.valid?).to eq(false)
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:owner) }
  end

  describe '.statuses' do
    it 'returns the array of valid status values' do
      expect(described_class.statuses).to eq ['processing', 'completed', 'failed']
    end
  end

  describe '#uploaded_file_url' do
    it 'returns nil when there is no file attached to the job' do
      expect(job.uploaded_file_url).to be(nil)
    end

    it 'returns a url when there is attached file' do
      gui_job.save!
      expect(gui_job.uploaded_file_url).to include('testing.pdf')
    end
  end

  describe '#uploaded_file_name' do
    it 'returns nil when there is no file attached to the job' do
      expect(job.uploaded_file_name).to be(nil)
    end

    it 'returns a url when there is attached file' do
      gui_job.save!
      expect(gui_job.uploaded_file_name).to eq('testing.pdf')
    end
  end

  describe '#completed?' do
    let(:job) { described_class.new }

    context 'when the job status is "completed"' do
      before { job.status = 'completed' }

      it 'returns true' do
        expect(job.completed?).to be true
      end
    end

    context 'when the job status is not "completed"' do
      before { job.status = 'failed' }

      it 'returns false' do
        expect(job.completed?).to be false
      end
    end
  end
end
