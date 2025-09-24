# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadForm do
  it { is_expected.to validate_presence_of :file }

  describe '#persist_to_tmp!' do
    let(:form) { described_class.new(file: file) }
    let(:persisted_path) { form.persist_to_tmp! }

    context 'when a file is provided' do
      let(:file) { fixture_file_upload('testing.pdf', 'application/pdf') }

      it 'returns a path to the uploaded file' do
        expect(persisted_path).to match(%r{/app/tmp/uploads/[\w-]+_testing\.pdf})
      end

      it 'writes the file to the tmp directory' do
        expect(File.exist?(persisted_path)).to be true
        expect(File.binread(persisted_path)).to eq(file.read)
      end
    end

    context 'when no file is provided' do
      let(:file) { nil }

      it 'returns nil' do
        expect(persisted_path).to be_nil
      end
    end
  end
end
