# frozen_string_literal: true

class RemediationStatusNotificationJob < ApplicationJob
  def perform(_job_uuid)
    # temporary stub until we implement the webhook
    nil
  end
end
