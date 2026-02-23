# frozen_string_literal: true

class PdfJob < Job
  belongs_to :owner, polymorphic: true
  validates :source_url, format: { with: URI::RFC2396_PARSER.make_regexp }, if: -> { owner_type == 'APIUser' }

  delegate :webhook_endpoint, :webhook_key, to: :owner, prefix: false

  def output_url_expired?
    output_url_expires_at.present? && output_url_expires_at < Time.zone.now
  end

  private

    def broadcast_to_job_channel
      JobChannel.broadcast_to(self, {
                                output_object_key: output_object_key,
                                status: status,
                                output_url: output_url,
                                output_url_expired: output_url_expired?,
                                finished_at: finished_at,
                                processing_error_message: processing_error_message
                              })
    end
end
