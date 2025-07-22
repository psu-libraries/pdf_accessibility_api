# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    uuid { SecureRandom.uuid }
    source_url { 'https://test.com/url' }
    status { 'processing' }
    owner factory: %i[api_user]
  end

  trait :gui_user_job do
    owner factory: %i[gui_user]
    source_url { nil }

    after(:build) do |job|
      job.file.attach(
        io: File.open('spec/fixtures/files/testing.pdf'),
        filename: 'testing.pdf',
        content_type: 'application/pdf'
      )
    end
  end
end
