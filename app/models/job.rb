# frozen_string_literal: true

class Job < ApplicationRecord
  has_one_attached :file
  def self.statuses
    ['processing', 'completed', 'failed']
  end

  validates :status, inclusion: { in: statuses }
  validates :source_url, format: { with: URI::RFC2396_PARSER.make_regexp }

  belongs_to :owner, polymorphic: true
end
