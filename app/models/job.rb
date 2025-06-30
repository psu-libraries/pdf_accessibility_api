# frozen_string_literal: true

class Job < ApplicationRecord
  def self.statuses
    ['processing', 'completed', 'failed']
  end

  validates :status, inclusion: { in: statuses }

  belongs_to :api_user
end
