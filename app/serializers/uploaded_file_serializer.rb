# frozen_string_literal: true

class UploadedFileSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(file)
    super(
      'content_type' => file.content_type,
      'headers' => file.headers,
      'original_filename' => file.original_filename
    )
  end

  # Converts serialized value into an Uploaded File.
  def deserialize(hash)
    ActionDispatch::Http::UploadedFile.new(hash['content_type'], hash['headers'], hash['original_filename'])
  end

  private

    # Checks if an argument should be serialized by this serializer.
    def klass
      ActionDispatch::Http::UploadedFile
    end
end
