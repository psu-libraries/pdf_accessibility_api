# frozen_string_literal: true

FactoryBot.define do
  factory :image_job do
    uuid { SecureRandom.uuid }
    status { 'processing' }
    type { ImageJob }
    owner factory: %i[gui_user]
  end
end
