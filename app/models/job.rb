# frozen_string_literal: true

class Job < ApplicationRecord
  after_commit :broadcast_to_job_channel
  belongs_to :owner, polymorphic: true

  def self.statuses
    ['processing', 'completed', 'failed']
  end

  validates :status, inclusion: { in: statuses }
  validates :page_count, numericality: { greater_than: 0, only_integer: true }, allow_nil: true

  def completed?
    status == 'completed'
  end

  private

    def broadcast_to_job_channel
      raise NotImplementedError, 'Subclasses must implement this method'
    end
end
