# frozen_string_literal: true

FactoryBot.define do
  factory :unit do
    name { 'Test Unit' }
    daily_page_limit { 100 }
    overall_page_limit { 1000 }
  end
end
