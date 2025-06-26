# frozen_string_literal: true

FactoryBot.define do
  factory :api_user do
    api_key { SecureRandom.hex(48) }
  end
end
