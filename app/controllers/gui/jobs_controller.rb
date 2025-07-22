# frozen_string_literal: true

class GUI::JobsController < GUIAuthController
  add_flash_types :info, :error, :warning
  def new
    @current_user = current_user
    @job = Job.new
  end

  def create
    job = current_user.jobs.build(job_params)
    job.status = 'processing'
    job.uuid = SecureRandom.uuid
    job.save!
    RemediationJob.perform_later(job.uuid)
    redirect_to action: 'new'
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = I18n.t('ui_page.upload.error')
    redirect_to action: 'new'
  end

  private

    def job_params
      params.require(:job).permit(:file)
    end
end
