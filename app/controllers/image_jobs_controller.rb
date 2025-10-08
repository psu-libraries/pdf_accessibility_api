# frozen_string_literal: true

class ImageJobsController < GUIAuthController
  add_flash_types :info, :error, :warning
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
    uploaded_io = params[:file]

    job = current_gui_user.image_jobs.build
    job.status = 'processing'
    job.uuid = SecureRandom.uuid
    job.save!

    ImageAltTextJob.perform_later(job.uuid, uploaded_io)
  end

end
