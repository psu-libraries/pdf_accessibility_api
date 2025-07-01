# frozen_string_literal: true

module API::V1
  class JobsController < BaseAPIController
    def create
      job = current_api_user.jobs.build(job_params)
      job.status = 'processing'
      job.uuid = SecureRandom.uuid
      job.save!

      RemediationJob.perform_later(job.uuid)

      render json: job, only: :uuid
    rescue ActiveRecord::RecordInvalid => e
      render json: { message: e.message, code: 422 }, status: :unprocessable_entity
    end

    private

      def job_params
        params.permit([:source_url])
      end
  end
end
