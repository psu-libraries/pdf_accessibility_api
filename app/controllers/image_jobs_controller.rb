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
    # get file from params
    # create job
    # save to tmp storage for file path
    # start alt-text-generation job
    # go to show page
  end

end
