# frozen_string_literal: true

class JobsController < GUIAuthController
  def index
    @jobs = current_user.jobs.order(created_at: :desc)
  end

  def show
    @job = current_user.jobs.find(params[:id])
  end
end
