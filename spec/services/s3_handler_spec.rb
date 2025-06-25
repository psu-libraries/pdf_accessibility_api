# frozen_string_literal: true

require 'rails_helper'

RSpec.describe S3Handler, type: :service do
  describe 'mocked S3 interactions' do
    let(:object_key) { 'test.pdf' }
    let(:bucket_name) { 'fake-bucket' }
    let(:local_path) { '/tmp/test.pdf' }
    let(:s3_resource) { instance_double(Aws::S3::Resource) }
    let(:bucket) { instance_double(Aws::S3::Bucket) }
    let(:s3_object) { instance_double(Aws::S3::Object) }

    before do
      allow(ENV).to receive(:fetch).with('AWS_REGION').and_return('us-east-1')
      allow(ENV).to receive(:fetch).with('AWS_ACCESS_KEY_ID').and_return('key')
      allow(ENV).to receive(:fetch).with('AWS_SECRET_ACCESS_KEY').and_return('secret')
      allow(ENV).to receive(:fetch).with('S3_BUCKET_NAME').and_return(bucket_name)
      allow(Aws::S3::Resource).to receive(:new).and_return(s3_resource)
      allow(s3_resource).to receive(:bucket).with(bucket_name).and_return(bucket)
    end

    describe '#upload_to_input' do
      it 'uploads a file to S3 input directory' do
        allow(bucket).to receive(:object).with("pdf/#{object_key}").and_return(s3_object)
        allow(s3_object).to receive(:upload_file).with(local_path)
        handler = described_class.new(object_key)
        handler.upload_to_input(local_path)
        expect(s3_object).to have_received(:upload_file).with(local_path)
      end
    end

    describe '#presigned_url_for_output' do
      it 'returns a presigned url if output file exists' do
        allow(bucket).to receive(:object).with("result/COMPLIANT_#{object_key}").and_return(s3_object)
        allow(s3_object).to receive(:exists?).and_return(true)
        allow(s3_object).to receive(:presigned_url).with(:get, expires_in: 3600).and_return('http://fake-url')
        handler = described_class.new(object_key)
        url = handler.presigned_url_for_output
        expect(url).to eq('http://fake-url')
      end

      it 'returns nil if output file does not exist' do
        allow(bucket).to receive(:object).with("result/COMPLIANT_#{object_key}").and_return(s3_object)
        allow(s3_object).to receive(:exists?).and_return(false)
        handler = described_class.new(object_key)
        expect(handler.presigned_url_for_output).to be_nil
      end
    end

    describe '#delete_files' do
      it 'deletes input and output files if they exist' do
        input_object = instance_double(Aws::S3::Object)
        output_object = instance_double(Aws::S3::Object)
        allow(bucket).to receive(:object).with("pdf/#{object_key}").and_return(input_object)
        allow(bucket).to receive(:object).with("result/COMPLIANT_#{object_key}").and_return(output_object)
        allow(input_object).to receive(:exists?).and_return(true)
        allow(output_object).to receive(:exists?).and_return(true)
        allow(input_object).to receive(:delete)
        allow(output_object).to receive(:delete)
        handler = described_class.new(object_key)
        handler.delete_files
        expect(input_object).to have_received(:delete)
        expect(output_object).to have_received(:delete)
      end

      it 'returns nil if no files exist' do
        allow(bucket).to receive(:object).with("pdf/#{object_key}").and_return(s3_object)
        allow(bucket).to receive(:object).with("result/COMPLIANT_#{object_key}").and_return(s3_object)
        allow(s3_object).to receive(:exists?).and_return(false)
        handler = described_class.new(object_key)
        expect(handler.delete_files).to be_nil
      end
    end
  end

  describe 'live S3 interactions' do
    # This test requires AWS credentials and an S3 bucket to connect to
    # It takes several minutes to complete, so it should be ran in isolation
    it 'uploads file, retrieves presigned URL from output, and deletes files', :live_s3 do
      file_path = Rails.root.join('spec', 'fixtures', 'files', 'testing.pdf')
      object_key = "testing-#{SecureRandom.uuid}.pdf"
      handler = described_class.new(object_key)
      handler.upload_to_input(file_path)
      url = nil
      Timeout.timeout(360) do
        loop do
          url = described_class.new(object_key).presigned_url_for_output
          break if url

          puts 'Waiting for processed file...'
          sleep 15
        end
      end
      expect(url).to match(%r{https://#{ENV.fetch('S3_BUCKET_NAME',
                                                  nil)}.s3.amazonaws.com/result/COMPLIANT_#{object_key}})
      handler.delete_files
    end
  end
end
