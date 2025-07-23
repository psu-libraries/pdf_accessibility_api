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
    job = current_user.jobs.build
    job.status = 'processing'
    job.uuid = SecureRandom.uuid
    job.save!
    uploaded_file = params[:file]
    RemediationJob.perform_later(job.uuid, file_path: uploaded_file.path,
                                           original_filename: uploaded_file.original_filename)

    redirect_to jobs_path, notice: I18n.t('ui_page.upload.success')
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = I18n.t('ui_page.upload.error') + e.message
    redirect_to action: 'new'
  end

  private

    def job_params
      params.permit(:file)
    end
end
