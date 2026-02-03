# frozen_string_literal: true

class Unit < ApplicationRecord
  has_many :api_users, dependent: :restrict_with_exception
  has_many :gui_users, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :daily_page_limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :overall_page_limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
