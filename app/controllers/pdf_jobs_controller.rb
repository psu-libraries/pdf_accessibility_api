# frozen_string_literal: true

class PdfJobsController < GUIAuthController
  protect_from_forgery except: [:sign]
  add_flash_types :info, :error, :warning
  def index
    @pdf_jobs = current_user.pdf_jobs.order(created_at: :desc)
  end

  def show
    @pdf_job = current_user.pdf_jobs.find(params[:id])
  end

  def new
    @current_user = current_user
    @pdf_job = PdfJob.new
  end

  def sign
    filename = params[:filename]
    page_count = params[:page_count]

    PageCountQuotaValidator.validate!(owner: current_user, page_count: page_count)

    object_key = "#{SecureRandom.hex(8)}_#{filename}"
    s3_handler = S3Handler.new(object_key)
    render json: s3_handler.presigned_url_for_input
  rescue PageCountQuotaValidator::Error => e
    render json: { message: e.message.humanize,
                   code: 422 }, status: :unprocessable_entity
  end

  def complete
    object_key = params[:object_key]
    page_count = params[:page_count]
    pdf_job = current_user.pdf_jobs.build
    pdf_job.status = 'processing'
    pdf_job.uuid = SecureRandom.uuid
    pdf_job.output_object_key = object_key
    pdf_job.page_count = page_count
    pdf_job.save!
    GUIRemediationJob.perform_later(pdf_job.uuid, object_key)
    render json: { job_id: pdf_job.id }, status: :created
  end
end
