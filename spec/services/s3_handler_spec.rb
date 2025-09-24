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
    let(:handler) { described_class.new(object_key) }
    let(:job_id) { '1' }
    let(:content_type) { 'application/pdf' }
    let(:signer) { instance_double Aws::S3::Presigner }
    let(:url) { 'www.response_example.com' }

    before do
      allow(ENV).to receive(:fetch).with('AWS_REGION').and_return('us-east-1')
      allow(ENV).to receive(:fetch).with('AWS_ACCESS_KEY_ID').and_return('key')
      allow(ENV).to receive(:fetch).with('AWS_SECRET_ACCESS_KEY').and_return('secret')
      allow(ENV).to receive(:fetch).with('S3_BUCKET_NAME').and_return(bucket_name)
      allow(Aws::S3::Resource).to receive(:new).and_return(s3_resource)
      allow(s3_resource).to receive(:bucket).with(bucket_name).and_return(bucket)
    end

    describe '#upload_to_input' do
      before do
        allow(bucket).to receive(:object).with("pdf/#{object_key}").and_return(s3_object)
        allow(s3_object).to receive(:upload_file).with(local_path)
      end

      it 'uploads a file to S3 input directory' do
        handler.upload_to_input(local_path)
        expect(s3_object).to have_received(:upload_file).with(local_path)
      end

      context 'when an error is raised during the upload' do
        before { allow(s3_object).to receive(:upload_file).and_raise(Aws::Errors::ServiceError.new(nil, 'AWS error')) }

        it 're-raises an S3Handler::Error' do
          expect { handler.upload_to_input(local_path) }.to raise_error(S3Handler::Error, 'AWS error')
        end
      end
    end

    describe '#presigned_url_for_output' do
      before do
        allow(bucket).to receive(:object).with("result/COMPLIANT_#{object_key}").and_return(s3_object)
        allow(s3_object).to receive(:exists?).and_return(true)
      end

      it 'returns a presigned url if output file exists' do
        allow(s3_object).to receive(:presigned_url).with(:get, expires_in: 3600).and_return('http://fake-url')
        url = handler.presigned_url_for_output
        expect(url).to eq('http://fake-url')
      end

      it 'returns nil if output file does not exist' do
        allow(s3_object).to receive(:exists?).and_return(false)
        expect(handler.presigned_url_for_output).to be_nil
      end

      context 'when an error is raised while retrieving the URL' do
        before { allow(s3_object).to receive(:presigned_url).and_raise(Aws::Errors::ServiceError.new(nil, 'AWS error')) }

        it 're-raises an S3Handler::Error' do
          expect { handler.presigned_url_for_output }.to raise_error(S3Handler::Error, 'AWS error')
        end
      end
    end

    describe '#presigned_url_for_input' do
      before do
        allow(signer).to receive(:presigned_url).and_return(url)
        allow(Aws::S3::Presigner).to receive(:new).and_return signer
      end

      it 'returns json with the url, headers, job_id, and object_key' do
        expect(handler.presigned_url_for_input(object_key, content_type, job_id)).to eq(
          {
            url: url,
            headers: { 'Content-Type' => content_type.to_s, 'x-amz-acl' => 'private' },
            job_id: job_id,
            object_key: object_key
          }
        )
      end

      it "calls the AWS Signer's #presigned_url method" do
        handler.presigned_url_for_input(object_key, content_type, job_id)
        expect(signer).to have_received(:presigned_url).with(
          :put_object,
          bucket: ENV.fetch('S3_BUCKET_NAME'),
          key: object_key,
          acl: 'private',
          content_type: content_type,
          expires_in: 900
        )
      end
    end
  end
end
