# frozen_string_literal: true

class APIUser < ApplicationRecord
  belongs_to :unit, optional: true

  has_many :jobs, as: :owner, dependent: :restrict_with_exception
  has_many :pdf_jobs, as: :owner, dependent: :restrict_with_exception

  before_create :set_keys

  validates :webhook_endpoint, presence: true
  validates :webhook_endpoint, format: { with: URI::RFC2396_PARSER.make_regexp('https') }

  private

    def set_keys
      self.api_key ||= "api_key_#{SecureRandom.hex(48)}"
      self.webhook_key ||= "wh_key_#{SecureRandom.hex(48)}"
    end
end
