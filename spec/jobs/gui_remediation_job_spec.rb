# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GUIRemediationJob do
  let!(:gui_job) { create(:pdf_job, :gui_user_job) }
  let(:s3) {
    instance_spy(
      S3Handler,
      presigned_url_for_output: output_url
    )
  }
  let(:output_url) { 'https://example.com/presigned-file-url' }
  let(:file_path) { './spec/fixtures/files/testing.pdf' }
  let(:object_key) { "#{SecureRandom.hex(8)}_testing.pdf" }

  before do
    allow(S3Handler).to receive(:new).and_return s3
    allow(RemediationStatusNotificationJob).to receive(:perform_later)
    allow(File).to receive(:delete).with(file_path)
  end

  describe '#perform' do
    context 'when the job is called with file_path and object_key arguments' do
      before do
        described_class.perform_now(gui_job.uuid, object_key)
      end

      it 'does not upload to S3 (this is done by uppy)' do
        expect(s3).not_to have_received(:upload_to_input).with(file_path)
      end

      it 'updates the status and metadata of the given job record' do
        reloaded_job = gui_job.reload
        expect(reloaded_job.status).to eq 'completed'
        expect(reloaded_job.output_url).to eq 'https://example.com/presigned-file-url'
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.output_url_expires_at).to be_within(1.minute)
          .of(AppJobModule::PRESIGNED_URL_EXPIRES_IN.seconds.from_now)
      end

      it 'does not queue up a notification about the status of the job' do
        expect(RemediationStatusNotificationJob).not_to have_received(:perform_later).with(gui_job.uuid)
      end
    end

    context 'when an output file is not produced before the timeout is exceeded' do
      let(:output_url) { nil }

      it 'updates the status and metadata of the given job record' do
        described_class.perform_now(gui_job.uuid, object_key, output_polling_timeout: 1)
        reloaded_job = gui_job.reload
        expect(reloaded_job.status).to eq 'failed'
        expect(reloaded_job.output_url).to be_nil
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.processing_error_message).to eq 'Timed out waiting for output file'
        expect(reloaded_job.output_url_expires_at).to be_nil
      end

      it 'does not queue up a notification' do
        described_class.perform_now(gui_job.uuid, object_key, output_polling_timeout: 1)
        expect(RemediationStatusNotificationJob).not_to have_received(:perform_later).with(gui_job.uuid)
      end
    end

    context 'when an error occurs while uploading the source file' do
      before do
        allow(s3).to receive(:presigned_url_for_output).and_raise(S3Handler::Error.new('upload error'))
      end

      it 'updates the status and metadata of the given job record' do
        described_class.perform_now(gui_job.uuid, object_key)
        reloaded_job = gui_job.reload
        expect(reloaded_job.status).to eq 'failed'
        expect(reloaded_job.output_url).to be_nil
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.processing_error_message).to eq(
          'Failed to upload file to remediation input location:  upload error'
        )
        expect(reloaded_job.output_url_expires_at).to be_nil
      end

      it 'does not queue up a notification' do
        described_class.perform_now(gui_job.uuid, object_key)
        expect(RemediationStatusNotificationJob).not_to have_received(:perform_later).with(gui_job.uuid)
      end
    end
  end
end
