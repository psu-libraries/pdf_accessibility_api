# frozen_string_literal: true

class GUIUser < ApplicationRecord
  has_many :jobs, as: :owner, dependent: :restrict_with_exception
  has_many :pdf_jobs, as: :owner, dependent: :restrict_with_exception
  has_many :image_jobs, as: :owner, dependent: :restrict_with_exception
end
