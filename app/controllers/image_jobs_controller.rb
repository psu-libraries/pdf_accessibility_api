# frozen_string_literal: true

class ImageJobsController < GUIAuthController
  protect_from_forgery with: :null_session, only: [:create]
  def index
    @image_jobs = current_user.image_jobs.order(created_at: :desc)
  end

  def show
    @image_job = current_user.image_jobs.find(params[:id])
  end

  def new
    @current_user = current_user
  end

  def create
    uploads_tmp_dir = Rails.root.join('tmp/uploads')
    uploaded_file = params[:image]
    object_key = "#{SecureRandom.uuid}_#{uploaded_file.original_filename}"
    tmp_path = uploads_tmp_dir.join(object_key).to_s
    File.binwrite(tmp_path, uploaded_file.read)
    job = current_user.image_jobs.build
    job.output_object_key = uploaded_file.original_filename
    job.status = 'processing'
    job.uuid = SecureRandom.uuid
    job.save!

    ImageAltTextJob.perform_later(job.uuid, tmp_path)
    render json: { 'jobId' => job.id }
  end
end
