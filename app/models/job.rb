# frozen_string_literal: true

class Job < ApplicationRecord
  def self.statuses
    ['processing', 'completed', 'failed']
  end

  validates :status, inclusion: { in: statuses }
  validates :source_url, format: { with: URI::RFC2396_PARSER.make_regexp }, if: -> { owner_type == 'APIUser' }
  belongs_to :owner, polymorphic: true
  delegate :webhook_endpoint, :webhook_key, to: :owner, prefix: false

  def completed?
    status == 'completed'
  end

  def output_url_expired?
    output_url_expires_at.present? && output_url_expires_at < Time.zone.now
  end
end
