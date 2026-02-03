# frozen_string_literal: true

FactoryBot.define do
  factory :unit do
    name { 'Test Unit' }
    daily_page_limit { 30 }
    overall_page_limit { 25000 }
  end
end
