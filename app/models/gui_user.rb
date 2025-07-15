# frozen_string_literal: true

class GUIUser < ApplicationRecord
  has_many :jobs, as: :owner, dependent: :restrict_with_exception
end
