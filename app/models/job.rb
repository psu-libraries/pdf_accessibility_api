# frozen_string_literal: true

class Job < ApplicationRecord
  def self.statuses
    ['processing', 'completed', 'failed']
  end

  validates :status, inclusion: { in: statuses }
  validates :source_url, presence: true, if > { owner_type == 'APIUser' }
  belongs_to :owner, polymorphic: true
  delegate :webhook_endpoint, :webhook_key, to: :owner, prefix: false

  def completed?
    status == 'completed'
  end

end
