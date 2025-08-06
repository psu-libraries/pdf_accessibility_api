# frozen_string_literal: true

class UploadForm
  UPLOADS_TMP_DIR = Rails.root.join(ENV.fetch('UPLOADS_TMP_DIR', 'tmp/uploads'))

  include ActiveModel::Validations
  include ActiveModel::Model

  attr_accessor :file

  validates :file, presence: true

  def persist_to_tmp!
    return unless valid?

    tmp_path = UPLOADS_TMP_DIR.join("#{SecureRandom.uuid}_#{file.original_filename}")
    File.binwrite(tmp_path, file.read)
    file.rewind if file.respond_to?(:rewind)
    tmp_path.to_s
  end
end
