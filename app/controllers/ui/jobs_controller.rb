# frozen_string_literal: true

class Ui::JobsController < ApplicationController
  def new
    # implement
  end

  def create
    # TODO define current_gui_user
    # TODO define source url
    job = current_gui_user.jobs.build(job_params)
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
