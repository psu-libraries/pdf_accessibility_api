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
  let!(:file_path) { Rack::Test::UploadedFile.new(File.new("#{Rails.root}/spec/fixtures/files/lion.jpg"),
                                                  'image/jpg',
                                                  original_filename: 'lion.jpg').path }

  around do |example|
    ClimateControl.modify(
      'AWS_ACCESS_KEY_ID' => 'test-access-key',
      'AWS_SECRET_ACCESS_KEY' => 'test-secret-key',
      'AWS_REGION' => 'test-region',
      'LLM_MODEL' => 'test-llm-model'
    ) do
      example.run
    end
  end

  before do
    allow(AltText::Client).to receive(:new).and_return alt_text_gem
    allow(AltText::LLMRegistry).to receive(:resolve).and_return 'resolved-model-name'
  end

  describe '#perform' do
    context 'when the job is called with job uuid and file' do
      before do
        described_class.perform_now(job.uuid, file_path)
      end

      it 'calls the Alt Text gem' do
        expect(alt_text_gem).to have_received(:process_image).with(
          /.+\.jpg/, prompt: File.read('prompt.txt'), model_id: 'test-llm-model'
        )
      end

      it 'initializes AltText::Client with ENV-based config' do
        expect(AltText::Client).to have_received(:new).with(
          access_key: 'test-access-key',
          secret_key: 'test-secret-key',
          region: 'test-region'
        )
      end

      it 'updates the alt_text of the given image job record' do
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'completed'
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.alt_text).to eq(alt_text_response)
        expect(reloaded_job.llm_model).to eq('resolved-model-name')
      end
    end

    context 'when an error occurs while uploading the image file' do
      before do
        allow(alt_text_gem).to receive(:process_image).and_raise(StandardError)
      end

      it 'updates the status and metadata of the given image job record' do
        described_class.perform_now(job.uuid, file_path)
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'failed'
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.processing_error_message).to eq 'StandardError'
        expect(reloaded_job.alt_text).to be_nil
      end
    end
  end
end
