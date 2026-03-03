# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckS3ForFinalFilesService do
  subject(:service) { described_class.new }

  let!(:job) do
    create(
      :pdf_job,
      status: 'processing',
      object_key: 'object-key',
      filename: 'original.pdf',
      created_at: 10.minutes.ago
    )
  end

  before do
    allow(service).to receive(:sleep) # stub sleep to go fast # rubocop:disable RSpec/SubjectStub
    allow(RemediationStatusNotificationJob).to receive(:perform_later)
  end

  describe '#call' do
    context 'when S3 has an output file available' do
      it 'marks the job completed and stores the output URL' do
        s3_handler = instance_double(S3Handler)
        allow(S3Handler).to receive(:new).with('object-key').and_return(s3_handler)
        allow(s3_handler).to receive(:presigned_url_for_output)
          .with('original.pdf', expires_in: AppJobModule::PRESIGNED_URL_EXPIRES_IN)
          .and_return('https://example.com/output.pdf')

        service.call(run_once: true)

        reloaded_job = job.reload
        expect(reloaded_job.status).to eq('completed')
        expect(reloaded_job.output_url).to eq('https://example.com/output.pdf')
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(reloaded_job.output_url_expires_at).to be_present
        expect(RemediationStatusNotificationJob).to have_received(:perform_later).with(job.uuid)
      end

      context 'when the job owner is not an APIUser' do
        let(:owner) { create(:gui_user) }
        let!(:job) do
          create(
            :pdf_job,
            owner: owner,
            status: 'processing',
            object_key: 'object-key',
            filename: 'original.pdf',
            created_at: 10.minutes.ago
          )
        end

        it 'does not queue a remediation status notification' do
          s3_handler = instance_double(S3Handler)
          allow(S3Handler).to receive(:new).with('object-key').and_return(s3_handler)
          allow(s3_handler).to receive(:presigned_url_for_output)
            .with('original.pdf', expires_in: AppJobModule::PRESIGNED_URL_EXPIRES_IN)
            .and_return('https://example.com/output.pdf')

          service.call(run_once: true)

          reloaded_job = job.reload
          expect(reloaded_job.status).to eq('completed')
          expect(reloaded_job.output_url).to eq('https://example.com/output.pdf')
          expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
          expect(reloaded_job.output_url_expires_at).to be_present
          expect(RemediationStatusNotificationJob).not_to have_received(:perform_later)
        end
      end
    end

    context 'when the job has exceeded the polling time limit' do
      let!(:job) do
        create(
          :pdf_job,
          status: 'processing',
          object_key: 'object-key',
          created_at: 2.hours.ago
        )
      end

      it 'marks the job failed with a timeout message' do
        allow(S3Handler).to receive(:new)

        service.call(run_once: true)

        reloaded_job = job.reload
        expect(reloaded_job.status).to eq('failed')
        expect(reloaded_job.processing_error_message).to eq('Timed out waiting for output file')
        expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
        expect(RemediationStatusNotificationJob).to have_received(:perform_later).with(job.uuid)
      end

      context 'when the job owner is not an APIUser' do
        let(:owner) { create(:gui_user) }
        let!(:job) do
          create(
            :pdf_job,
            owner: owner,
            status: 'processing',
            object_key: 'object-key',
            created_at: 2.hours.ago
          )
        end

        it 'does not queue a remediation status notification' do
          allow(S3Handler).to receive(:new)

          service.call(run_once: true)

          reloaded_job = job.reload
          expect(reloaded_job.status).to eq('failed')
          expect(reloaded_job.processing_error_message).to eq('Timed out waiting for output file')
          expect(reloaded_job.finished_at).to be_within(1.minute).of(Time.zone.now)
          expect(RemediationStatusNotificationJob).not_to have_received(:perform_later)
        end
      end
    end

    context 'when an error occurs while checking a job' do
      it 'rescues the error and reports it to Bugsnag' do
        allow(Bugsnag).to receive(:notify)
        allow(S3Handler).to receive(:new).and_raise(StandardError, 'error')

        expect { service.call(run_once: true) }.not_to raise_error
        expect(Bugsnag).to have_received(:notify)
        expect(job.reload.status).to eq('processing')
      end
    end

    context 'when the job is missing object_key' do
      let!(:job) do
        create(
          :pdf_job,
          status: 'processing',
          object_key: nil,
          filename: 'original.pdf',
          created_at: 10.minutes.ago
        )
      end

      it 'skips checking S3' do
        allow(S3Handler).to receive(:new)

        service.call(run_once: true)

        expect(S3Handler).not_to have_received(:new)
        expect(job.reload.status).to eq('processing')
      end
    end

    context 'when the job is missing filename' do
      let!(:job) do
        create(
          :pdf_job,
          status: 'processing',
          object_key: 'object-key',
          filename: nil,
          created_at: 10.minutes.ago
        )
      end

      it 'skips checking S3' do
        allow(S3Handler).to receive(:new)

        service.call(run_once: true)

        expect(S3Handler).not_to have_received(:new)
        expect(job.reload.status).to eq('processing')
      end
    end

    context 'when the job record is stale in memory' do
      let!(:job) do
        create(
          :pdf_job,
          status: 'processing',
          object_key: nil,
          filename: nil,
          created_at: 10.minutes.ago
        )
      end

      it 'reloads the job before checking S3' do
        stale_job = PdfJob.find(job.id)
        PdfJob.where(id: job.id).update_all(object_key: 'object-key', filename: 'original.pdf') # rubocop:disable Rails/SkipsModelValidations

        processing_jobs = instance_double(ActiveRecord::Relation)
        allow(processing_jobs).to receive(:none?).and_return(false)
        allow(processing_jobs).to receive(:find_each).and_yield(stale_job)
        allow(Job).to receive(:processing_pdfjobs).and_return(processing_jobs)

        s3_handler = instance_double(S3Handler)
        allow(S3Handler).to receive(:new).with('object-key').and_return(s3_handler)
        allow(s3_handler).to receive(:presigned_url_for_output)
          .with('original.pdf', expires_in: AppJobModule::PRESIGNED_URL_EXPIRES_IN)
          .and_return(nil)

        service.call(run_once: true)

        expect(S3Handler).to have_received(:new).with('object-key')
      end
    end

    context 'when there are many processing jobs' do
      let(:owner) { create(:api_user) }

      let!(:jobs) do
        (1..25).map do |i|
          create(
            :pdf_job,
            owner: owner,
            status: 'processing',
            object_key: "bulk-key-#{i}",
            filename: "file-#{i}.pdf",
            created_at: 10.minutes.ago
          )
        end
      end

      it 'iterates through all processing jobs' do
        job.update(status: 'completed') # Mark the original job as completed so it doesn't interfere

        s3_handler = instance_double(S3Handler)
        allow(s3_handler).to receive(:presigned_url_for_output).and_return(nil)

        seen_keys = []
        allow(S3Handler).to receive(:new) do |key|
          seen_keys << key
          s3_handler
        end

        service.call(run_once: true)

        expect(seen_keys).to match_array(jobs.map(&:object_key))
      end
    end

    context 'when the OS sends a termination signal' do
      it 'stops after the current iteration' do
        traps = {}
        allow(Signal).to receive(:trap) do |signal, &block|
          traps[signal] = block
        end

        allow(Job).to receive(:processing_pdfjobs).once.and_call_original

        # rubocop:disable RSpec/SubjectStub
        allow(service).to receive(:sleep) do
          traps['TERM']&.call
        end
        # rubocop:enable RSpec/SubjectStub

        s3_handler = instance_double(S3Handler)
        allow(S3Handler).to receive(:new).and_return(s3_handler)
        allow(s3_handler).to receive(:presigned_url_for_output).and_return(nil)

        # Run in `loop`; we expect it to terminate
        expect { service.call(run_once: false) }.not_to raise_error
        expect(Job).to have_received(:processing_pdfjobs).once
      end
    end
  end
end
