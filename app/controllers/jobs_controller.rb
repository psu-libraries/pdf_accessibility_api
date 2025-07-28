# frozen_string_literal: true

class JobsController < GUIAuthController
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
    RemediationJob.perform_later(job.uuid, file_path: uploaded_file.path,
                                           original_filename: uploaded_file.original_filename)

    redirect_to jobs_path, notice: I18n.t('upload.success')
    uploaded_file.close
  rescue ActiveModel::ValidationError
    flash[:alert] = I18n.t('upload.error')
    redirect_to action: 'new'
  rescue StandardError => e
    flash[:alert] = "Exception: #{e.message}"
    redirect_to action: 'new'
  end
end
