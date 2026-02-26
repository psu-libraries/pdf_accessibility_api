# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckS3ForFinalFilesService do
  subject(:service) { described_class.new }

  let!(:job) do
    create(
      :pdf_job,
      status: 'processing',
      output_object_key: 'output-key',
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
        allow(S3Handler).to receive(:new).with('output-key').and_return(s3_handler)
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
            output_object_key: 'output-key',
            filename: 'original.pdf',
            created_at: 10.minutes.ago
          )
        end

        it 'does not queue a remediation status notification' do
          s3_handler = instance_double(S3Handler)
          allow(S3Handler).to receive(:new).with('output-key').and_return(s3_handler)
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
          output_object_key: 'output-key',
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
            output_object_key: 'output-key',
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
