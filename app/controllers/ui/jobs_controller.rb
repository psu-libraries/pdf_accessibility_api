# frozen_string_literal: true

class Ui::JobsController < ApplicationController
  def new
    @job = Job.new
  end

  def create
    # TODO define current user (part of ticket #38)
    job = current_user.jobs.build(job_params)
    gui = GUIUser.new
    job = gui.jobs.build(job_params)
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
      params.require(:job).permit(:file, :source_url)
    end
end
