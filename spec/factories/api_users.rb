# frozen_string_literal: true

FactoryBot.define do
  factory :api_user do
    webhook_endpoint { 'https://test.com/endpoint' }
  end
end
