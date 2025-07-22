# frozen_string_literal: true

class Job < ApplicationRecord
  has_one_attached :file
  def self.statuses
    ['processing', 'completed', 'failed']
  end

  validates :status, inclusion: { in: statuses }
  validate :has_file_or_source_url?
  belongs_to :owner, polymorphic: true
  delegate :webhook_endpoint, :webhook_key, to: :owner, prefix: false

  def completed?
    status == 'completed'
  end

  def uploaded_file_url
    return nil if file.blank?

    Rails.application.routes.url_helpers.rails_blob_url(file, host: ENV.fetch('SITE_HOST', nil))
  end

  def uploaded_file_name
    return nil if file.blank?

    file.blob.filename.to_s
  end

  private

    def has_file_or_source_url?
      unless (source_url.present? && !!source_url.match(URI::RFC2396_PARSER.make_regexp)) || file.present?
        errors.add(:base, 'Job must have either an attached file or a source url present')
      end
    end
end
