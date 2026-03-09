# frozen_string_literal: true

class GUIUser < ApplicationRecord
  include OwnerHelpers

  belongs_to :unit, optional: true

  has_many :jobs, as: :owner, dependent: :restrict_with_exception
  has_many :pdf_jobs, as: :owner, dependent: :restrict_with_exception
  has_many :image_jobs, as: :owner, dependent: :restrict_with_exception

  RailsAdmin.config do |config|
    config.model 'GUIUser' do
      list do
        field :id
        field :email
        field :unit
        field :total_pages_processed_last_24_hours
        field :created_at
      end

      show do
        field :id
        field :email
        field :unit
        field :total_pages_processed_last_24_hours
        field :created_at
        field :updated_at
      end

      edit do
        field :email
        field :unit
        field :created_at do
          read_only true
        end
        field :updated_at do
          read_only true
        end
      end
    end
  end
end
