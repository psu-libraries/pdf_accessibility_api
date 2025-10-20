# frozen_string_literal: true

class ImageJob < Job
  belongs_to :owner, polymorphic: true

  private

    def broadcast_to_job_channel
      JobChannel.broadcast_to(self, {
                                alt_text: alt_text,
                                status: status,
                                finished_at: finished_at,
                                processing_error_message: processing_error_message
                              })
    end
end
