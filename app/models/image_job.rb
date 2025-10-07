# frozen_string_literal: true

class ImageJob < Job
  belongs_to :owner, polymorphic: true

  private

    def broadcast_to_job_channel
      # To be implemented in #160
    end
end
