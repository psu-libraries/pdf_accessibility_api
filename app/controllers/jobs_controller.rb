# frozen_string_literal: true

class JobsController < GUIAuthController
  include RemediationModule

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
    size         = params[:size].to_i

    job = current_user.jobs.build
    job.status = 'processing'
    job.uuid = SecureRandom.uuid
    job.save!
    object_key = create_object_key(filename)
    s3_handler = S3Handler.new(object_key)
    s3_handler.bucket
    render json: s3_handler.presigned_url_for_input(filename, content_type, job.id)
  end
end
