# frozen_string_literal: true

class APIUser < ApplicationRecord
  has_many :jobs

  before_create :set_keys

  private

    def set_keys
      self.api_key ||= 'api_key_' + SecureRandom.hex(48)
      self.webhook_key ||= 'wh_key_' + SecureRandom.hex(48)
    end
end
