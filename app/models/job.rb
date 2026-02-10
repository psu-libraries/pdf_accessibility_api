# frozen_string_literal: true

class Job < ApplicationRecord
  after_commit :broadcast_to_job_channel
  belongs_to :owner, polymorphic: true

  def self.statuses
    ['processing', 'completed', 'failed']
  end

  validates :status, inclusion: { in: statuses }

  def completed?
    status == 'completed'
  end

  RailsAdmin.config do |config|
    config.model 'Job' do
      list do
        field :uuid
        field :type
        field :status
        field :owner_type
        field :owner_id
        field :created_at
        field :finished_at
      end

      show do
        field :uuid
        field :type
        field :status
        field :llm_model
        field :prompt
        field :alt_text
        field :source_url
        field :output_url
        field :output_object_key
        field :output_url_expires_at
        field :processing_error_message
        field :owner_type
        field :owner_id
        field :created_at
        field :updated_at
        field :finished_at
      end
    end
  end

  private

    def broadcast_to_job_channel
      raise NotImplementedError, 'Subclasses must implement this method'
    end
end
