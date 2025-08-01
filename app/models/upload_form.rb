# frozen_string_literal: true

class UploadForm
  include ActiveModel::Validations
  include ActiveModel::Model

  attr_accessor :file

  validates :file, presence: true
end
