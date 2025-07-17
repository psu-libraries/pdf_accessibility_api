# frozen_string_literal: true

class Job < ApplicationRecord
  has_one_attached :file
  def self.statuses
    ['processing', 'completed', 'failed']
  end

  validates :status, inclusion: { in: statuses }
  validate :has_file_or_source_url

  belongs_to :owner, polymorphic: true

  def has_file_or_source_url
    unless source_url.present? && !!source_url.match(URI::RFC2396_PARSER.make_regexp) || file.present?
      errors.add(:base, 'Job must have either an attached file or a source url present')
    end
  end
end
