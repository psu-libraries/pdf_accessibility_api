# frozen_string_literal: true

class UploadedFileSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(file)
    tmp = Tempfile.new(['uploads/', File.extname(file.original_filename)])
    tmp.binmode

    file.tempfile.rewind
    IO.copy_stream(file.tempfile, tmp)
    tmp.flush   # make sure everything is written to disk

    payload = {
      'content_type'      => file.content_type,
      'headers'           => file.headers,
      'original_filename' => file.original_filename,
      'tempfile_path'     => tmp.path
    }
    super(payload)
  end

  # Converts serialized value into an Uploaded File.
  def deserialize(hash)
    ActionDispatch::Http::UploadedFile.new(
      content_type: hash['content_type'],
      headers: hash['headers'],
      filename: hash['original_filename'],
      tempfile:  File.open(hash["tempfile_path"])
      )
  end

  private

    # Checks if an argument should be serialized by this serializer.
    def klass
      ActionDispatch::Http::UploadedFile
    end
end
