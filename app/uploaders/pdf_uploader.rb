# frozen_string_literal: true

class PdfUploader < Shrine
  plugin :validation_helpers

  Attacher.validate do
    validate_mime_type_inclusion [‘application/pdf’]
  end

end
