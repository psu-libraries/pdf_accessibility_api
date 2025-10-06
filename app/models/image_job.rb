# frozen_string_literal: true

class ImageJob < Job
  belongs_to :owner, polymorphic: true
end
