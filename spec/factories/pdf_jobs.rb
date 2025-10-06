# frozen_string_literal: true

FactoryBot.define do
  factory :pdf_job do
    uuid { SecureRandom.uuid }
    source_url { 'https://test.com/url' }
    status { 'processing' }
    type { PdfJob }
    owner factory: %i[api_user]
  end

  trait :gui_user_job do
    owner factory: %i[gui_user]
    source_url { nil }
  end
end
