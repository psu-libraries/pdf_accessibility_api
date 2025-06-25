# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    uuid { SecureRandom.uuid }
    source_url { 'https://test.com/url' }
    status { 'processing' }
  end
end
