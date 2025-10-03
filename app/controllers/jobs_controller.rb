# frozen_string_literal: true

class JobsController < GUIAuthController
  protect_from_forgery except: [:sign]
  add_flash_types :info, :error, :warning
  def index
    @jobs = current_user.jobs.order(created_at: :desc)
  end

  def show
    @job = current_user.jobs.find(params[:id])
  end

  def new
    @current_user = current_user
    @job = Job.new
  end

  def sign
    filename     = params[:filename].presence || "upload/#{SecureRandom.uuid}"
    content_type = params[:content_type].presence || 'application/pdf'

    object_key = "#{SecureRandom.hex(8)}_#{filename}"
    s3_handler = S3Handler.new(object_key)
    render json: s3_handler.presigned_url_for_input(object_key, content_type)
  end

  def complete
    job = current_user.jobs.build
    job.status = 'processing'
    job.uuid = SecureRandom.uuid
    job.save!
    object_key = params[:object_key]
    GUIRemediationJob.perform_later(job.uuid, object_key)
    render json: { job_id: job.id }, status: :created
  end
end
