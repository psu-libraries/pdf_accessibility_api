# frozen_string_literal: true

class GUIUser < ApplicationRecord
  belongs_to :unit, optional: true

  has_many :jobs, as: :owner, dependent: :restrict_with_exception
  has_many :pdf_jobs, as: :owner, dependent: :restrict_with_exception
  has_many :image_jobs, as: :owner, dependent: :restrict_with_exception

  RailsAdmin.config do |config|
    config.model 'GuiUser' do
      list do
        field :id
        field :email
        field :created_at
      end

      edit do
        field :email
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
