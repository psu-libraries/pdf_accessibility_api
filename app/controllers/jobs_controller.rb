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

  def create
    uploaded_file = params[:file]
    form = UploadForm.new(file: uploaded_file)
    form.validate!

    job = current_user.jobs.build
    job.status = 'processing'
    job.uuid = SecureRandom.uuid
    job.save!

    persistent_path = form.persist_to_tmp!

    GUIRemediationJob.perform_later(job.uuid, persistent_path, uploaded_file.original_filename)

    redirect_to job_path(job), notice: I18n.t('upload.success')
  rescue ActiveModel::ValidationError
    flash[:alert] = I18n.t('upload.error')
    redirect_to action: 'new'
  rescue StandardError => e
    flash[:alert] = "Exception: #{e.message}"
    redirect_to action: 'new'
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
