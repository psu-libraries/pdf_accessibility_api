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
      it 'uploads a file to S3 input prefix' do
        expect(bucket).to receive(:object).with("pdf/#{object_key}").and_return(s3_object)
        expect(s3_object).to receive(:upload_file).with(local_path)
        handler = S3Handler.new(object_key)
        handler.upload_to_input(local_path)
      end
    end

    describe '#presigned_url_for_output' do
      it 'returns a presigned url if output file exists' do
        allow(bucket).to receive(:object).with("result/COMPLIANT_#{object_key}").and_return(s3_object)
        allow(s3_object).to receive(:exists?).and_return(true)
        expect(s3_object).to receive(:presigned_url).with(:get, expires_in: 3600).and_return('http://fake-url')
        handler = S3Handler.new(object_key)
        url = handler.presigned_url_for_output
        expect(url).to eq('http://fake-url')
      end

      it 'returns nil if output file does not exist' do
        allow(bucket).to receive(:object).with("result/COMPLIANT_#{object_key}").and_return(s3_object)
        allow(s3_object).to receive(:exists?).and_return(false)
        handler = S3Handler.new(object_key)
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
        expect(input_object).to receive(:delete)
        expect(output_object).to receive(:delete)
        handler = S3Handler.new(object_key)
        handler.delete_files
      end

      it 'returns nil if no files exist' do
        allow(bucket).to receive(:object).with("pdf/#{object_key}").and_return(s3_object)
        allow(bucket).to receive(:object).with("result/COMPLIANT_#{object_key}").and_return(s3_object)
        allow(s3_object).to receive(:exists?).and_return(false)
        handler = S3Handler.new(object_key)
        expect(handler.delete_files).to be_nil
      end
    end
  end

  describe 'live S3 interactions' do
    it 'uploads, retrieves presigned URL, and deletes files', :live_s3 do
      file_path = Rails.root.join('spec', 'fixtures', 'files', 'test.pdf')
      object_key = "test-#{SecureRandom.uuid}.pdf"
      handler = S3Handler.new(object_key)
      handler.upload_to_input(file_path)
      Timeout.timeout(6000) do
        loop do
          url = S3Handler.new(object_key).presigned_url_for_result
          handler.delete_files url if url
          
          puts 'Waiting for processed file...'
          sleep 1
        end
      end
    end
  end
end
