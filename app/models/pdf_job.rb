# frozen_string_literal: true

class PdfJob < Job
  belongs_to :owner, polymorphic: true
  validates :source_url, format: { with: URI::RFC2396_PARSER.make_regexp }, if: -> { owner_type == 'APIUser' }

  delegate :webhook_endpoint, :webhook_key, to: :owner, prefix: false

  def output_url_expired?
    output_url_expires_at.present? && output_url_expires_at < Time.zone.now
  end
end
