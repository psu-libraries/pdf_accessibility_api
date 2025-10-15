# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImageAltTextJob do
  let!(:job) { create(:image_job) }
  let!(:alt_text_response) { 'Generated Alt-text' }
  let(:alt_text_gem) {
    instance_spy(
      AltText::Client,
      process_image: alt_text_response
    )
  }
  let!(:file_upload) { Rack::Test::UploadedFile.new(File.new("#{Rails.root}/spec/fixtures/files/lion.jpg"),
                                                    'image/jpg',
                                                    original_filename: 'lion.jpg')}

  before do
    allow(AltText::Client).to receive(:new).and_return alt_text_gem
  end

  describe '#perform' do
    context 'when the job is called with job uuid and file' do
      before do
        described_class.perform_now(job.uuid, file_upload)
      end

      it 'calls the Alt Text gem' do
        expect(alt_text_gem).to have_received(:process_image).with(
          /.+\.jpg/, prompt: File.read('prompt.txt'), model_id: ENV.fetch('LLM_MODEL', nil)
        )
      end

      it 'updates the alt_text of the given image job record' do
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'completed'
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(job.reload.alt_text).to eq('Generated Alt-text')
      end
    end

    context 'when alt-text is not produced before the timeout is exceeded' do
      let(:alt_text_response) { nil }

      it 'updates the status and metadata of the given image job record' do
        described_class.perform_now(job.uuid, file_upload, output_polling_timeout: 1)
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'failed'
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.alt_text).to be_nil
        expect(reloaded_job.processing_error_message).to eq 'Timed out waiting for alt-text'
        expect(job.reload.alt_text).to be_nil
      end
    end

    context 'when an error occurs while uploading the image file' do
      before do
        allow(alt_text_gem).to receive(:process_image).and_raise(StandardError)
      end

      it 'updates the status and metadata of the given image job record' do
        described_class.perform_now(job.uuid, file_upload)
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'failed'
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.processing_error_message).to eq 'StandardError'
        expect(job.reload.alt_text).to be_nil
      end
    end
  end
end
