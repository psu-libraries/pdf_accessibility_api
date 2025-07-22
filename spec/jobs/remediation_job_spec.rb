# frozen_string_literal: true

require 'rails_helper'

class Tempfile
  include Down::NetHttp::DownloadedFile
end

RSpec.describe RemediationJob do
  let!(:job) { create(:job, source_url: 'https://test.com/file.pdf') }
  let(:file) {
    instance_double(
      Tempfile,
      close!: nil,
      original_filename: 'file.pdf',
      path: 'path/to/file'
    )
  }
  let(:s3) {
    instance_spy(
      S3Handler,
      presigned_url_for_output: output_url
    )
  }
  let(:output_url) { 'https://example.com/presigned-file-url' }

  before do
    allow(Down).to receive(:download).with('https://test.com/file.pdf').and_return file
    allow(S3Handler).to receive(:new).with(/[a-f0-9]{16}_file\.pdf/).and_return s3
    allow(RemediationStatusNotificationJob).to receive(:perform_later)
  end

  describe '#perform' do
    it "transfers the file from the given job's source URL to S3" do
      described_class.perform_now(job.uuid)
      expect(s3).to have_received(:upload_to_input).with('path/to/file')
    end

    it 'updates the status and metadata of the given job record' do
      described_class.perform_now(job.uuid)
      reloaded_job = job.reload
      expect(reloaded_job.status).to eq 'completed'
      expect(reloaded_job.output_url).to eq 'https://example.com/presigned-file-url'
      expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
      expect(reloaded_job.output_object_key).to match /[a-f0-9]{16}_file\.pdf/
      expect(reloaded_job.output_url_expires_at).to be_within(1.minute).of(3600.seconds.from_now)
    end

    it 'queues up a notification about the status of the job' do
      described_class.perform_now(job.uuid)
      expect(RemediationStatusNotificationJob).to have_received(:perform_later).with(job.uuid)
    end

    it 'closes the temporarily downloaded file' do
      described_class.perform_now(job.uuid)
      expect(file).to have_received(:close!)
    end

    context 'when an output file is not produced before the timeout is exceeded' do
      let(:output_url) { nil }

      it 'updates the status and metadata of the given job record' do
        described_class.perform_now(job.uuid, 1)
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'failed'
        expect(reloaded_job.output_url).to be_nil
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.output_object_key).to be_nil
        expect(reloaded_job.processing_error_message).to eq 'Timed out waiting for output file'
        expect(reloaded_job.output_url_expires_at).to be_nil
      end

      it 'queues up a notification about the status of the job' do
        described_class.perform_now(job.uuid, 1)
        expect(RemediationStatusNotificationJob).to have_received(:perform_later).with(job.uuid)
      end

      it 'closes the temporarily downloaded file' do
        described_class.perform_now(job.uuid, 1)
        expect(file).to have_received(:close!)
      end
    end

    context 'when an error occurs while downloading the source file' do
      before do
        allow(Down).to receive(:download).and_raise(Down::Error.new('download error'))
      end

      it 'updates the status and metadata of the given job record' do
        described_class.perform_now(job.uuid)
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'failed'
        expect(reloaded_job.output_url).to be_nil
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.output_object_key).to be_nil
        expect(reloaded_job.processing_error_message).to eq 'Failed to download file from source URL:  download error'
        expect(reloaded_job.output_url_expires_at).to be_nil
      end

      it 'queues up a notification about the status of the job' do
        described_class.perform_now(job.uuid)
        expect(RemediationStatusNotificationJob).to have_received(:perform_later).with(job.uuid)
      end
    end

    context 'when an error occurs while uploading the source file' do
      before do
        allow(s3).to receive(:upload_to_input).and_raise(S3Handler::Error.new('upload error'))
      end

      it 'updates the status and metadata of the given job record' do
        described_class.perform_now(job.uuid)
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'failed'
        expect(reloaded_job.output_url).to be_nil
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.output_object_key).to be_nil
        expect(reloaded_job.processing_error_message).to eq(
          'Failed to upload file to remediation input location:  upload error'
        )
        expect(reloaded_job.output_url_expires_at).to be_nil
      end

      it 'queues up a notification about the status of the job' do
        described_class.perform_now(job.uuid)
        expect(RemediationStatusNotificationJob).to have_received(:perform_later).with(job.uuid)
      end

      it 'closes the temporarily downloaded file' do
        described_class.perform_now(job.uuid)
        expect(file).to have_received(:close!)
      end
    end
  end
end
