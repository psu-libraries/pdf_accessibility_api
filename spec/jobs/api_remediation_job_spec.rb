# frozen_string_literal: true

require 'rails_helper'

class Tempfile
  include Down::NetHttp::DownloadedFile
end

RSpec.describe APIRemediationJob do
  let!(:job) { create(:pdf_job, source_url: 'https://test.com/file.pdf') }
  let(:reader) { instance_double(PDF::Reader, page_count: 2) }
  let(:file) {
    instance_double(
      Tempfile,
      close!: nil,
      original_filename: 'file.pdf',
      path: 'path/to/file'
    )
  }
  let(:special_chars) { 'special%characters!.pdf' }
  let!(:special_chars_job) { create(:pdf_job, source_url: "https://test.com/#{special_chars}") }
  let(:special_chars_file) {
    instance_double(
      Tempfile,
      close!: nil,
      original_filename: special_chars,
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
  let(:file_path) { './spec/fixtures/files/testing.pdf' }
  let(:original_filename) { 'testing.pdf' }

  before do
    allow(Down).to receive(:download).with('https://test.com/file.pdf').and_return file
    allow(Down).to receive(:download).with('https://test.com/special%characters!.pdf').and_return special_chars_file
    allow(PDF::Reader).to receive(:new).and_return(reader)
    allow(S3Handler).to receive(:new).and_return s3
    allow(RemediationStatusNotificationJob).to receive(:perform_later)
    allow(File).to receive(:delete).with(file_path)
  end

  describe '#perform' do
    context 'when the job has a source url' do
      it "transfers the file from the given job's source URL to S3" do
        described_class.perform_now(job.uuid)
        expect(s3).to have_received(:upload_to_input).with('path/to/file')
      end

      it 'closes the temporarily downloaded file' do
        described_class.perform_now(job.uuid)
        expect(file).to have_received(:close!)
      end

      context 'when the file has a special character' do
        it 'saves that special character to the jobs output_key' do
          described_class.perform_now(special_chars_job.uuid)
          expect(special_chars_job.reload.output_object_key).to eq(special_chars)
        end

        it 'strips the special character for the s3 bucket' do
          described_class.perform_now(special_chars_job.uuid)
          expect(S3Handler).to have_received(:new).with(match(/[a-f0-9]{16}_specialcharacters\.pdf/))
        end
      end

      context 'when the unit quota would be exceeded' do
        before do
          allow(PageCountQuotaValidator).to receive(:validate!).and_raise(
            PageCountQuotaValidator::QuotaExceededError,
            "page_count exceeds the unit's overall page limit of 1"
          )
        end

        it 'fails the job and does not upload to S3' do
          described_class.perform_now(job.uuid)
          reloaded_job = job.reload
          expect(reloaded_job.status).to eq 'failed'
          expect(reloaded_job.processing_error_message).to eq(
            'Failed to process job: PageCountQuotaValidator::QuotaExceededError: page_count ' \
            "exceeds the unit's overall page limit of 1"
          )
          expect(s3).not_to have_received(:upload_to_input)
        end
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
        expect(reloaded_job.processing_error_message).to eq 'Failed to process job: Down::Error: download error'
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
        expect(reloaded_job.processing_error_message).to eq(
          'Failed to process job: S3Handler::Error: upload error'
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

    context 'when an error occurs while reading the pdf for page counting' do
      before do
        allow(PDF::Reader).to receive(:new).and_raise(PDF::Reader::MalformedPDFError, 'bad pdf')
      end

      it 'fails the job and does not upload to S3' do
        described_class.perform_now(job.uuid)
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'failed'
        expect(reloaded_job.processing_error_message).to eq 'Failed to process job: PDF::Reader::MalformedPDFError: ' \
                                                            'bad pdf'
        expect(s3).not_to have_received(:upload_to_input)
      end
    end
  end
end
