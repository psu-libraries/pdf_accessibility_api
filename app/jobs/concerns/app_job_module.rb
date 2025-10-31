# frozen_string_literal: true

module AppJobModule
  OUTPUT_POLLING_INTERVAL = 10 # This value was picked somewhat arbitrarily. We may want to adjust.
  OUTPUT_POLLING_TIMEOUT = 3600 # The default 1-hour timeout is also arbitrary and should probably be adjusted.
  PRESIGNED_URL_EXPIRES_IN = 84_000

  def poll_and_update(job_uuid, object_key, output_polling_timeout)
    job = Job.find_by!(uuid: job_uuid)
    s3 = S3Handler.new(object_key)

    timer = 0
    until output_url = s3.presigned_url_for_output(job.output_object_key, expires_in: PRESIGNED_URL_EXPIRES_IN)
      sleep OUTPUT_POLLING_INTERVAL
      timer += OUTPUT_POLLING_INTERVAL

      if timer > output_polling_timeout
        update_with_failure(job, 'Timed out waiting for output file')
        return true
      end
    end
    update_job(job, output_url, object_key)
  rescue S3Handler::Error => e
    # We may want to retry the upload depending on the more specific nature of the failure.
    update_with_failure(job, "Failed to upload file to remediation input location:  #{e.message}")
  end

  private

    def update_job(job, output_url, _object_key)
      job.update(
        status: 'completed',
        finished_at: Time.zone.now,
        output_url: output_url,
        output_url_expires_at: PRESIGNED_URL_EXPIRES_IN.seconds.from_now
      )
    end

    def update_with_failure(job, message)
      job.update(
        status: 'failed',
        finished_at: Time.zone.now,
        processing_error_message: message
      )
    end
end
