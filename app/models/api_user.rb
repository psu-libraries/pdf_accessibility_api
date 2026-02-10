# frozen_string_literal: true

class APIUser < ApplicationRecord
  has_many :jobs, as: :owner, dependent: :restrict_with_exception
  has_many :pdf_jobs, as: :owner, dependent: :restrict_with_exception

  before_create :set_keys

  validates :webhook_endpoint, presence: true
  validates :webhook_endpoint, format: { with: URI::RFC2396_PARSER.make_regexp('https') }

  RailsAdmin.config do |config|
    config.model 'ApiUser' do
      list do
        field :id
        field :name
        field :email
        field :created_at
        field :updated_at
      end

      show do
        field :id
        field :name
        field :email
        field :api_key
        field :webhook_key
        field :webhook_endpoint
        field :created_at
        field :updated_at
      end

      edit do
        field :name
        field :email

        field :api_key do
          read_only true
          help 'API keys are generated automatically'
        end

        field :webhook_key do
          read_only true
          help 'Webhook keys are generated automatically'
        end

        field :webhook_endpoint

        field :created_at do
          read_only true
        end

        field :updated_at do
          read_only true
        end
      end
    end
  end

  private

    def set_keys
      self.api_key ||= "api_key_#{SecureRandom.hex(48)}"
      self.webhook_key ||= "wh_key_#{SecureRandom.hex(48)}"
    end
end
