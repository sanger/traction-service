# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'

require 'webmock/rspec'

RSpec.describe Emq::Encoder do
  let(:pacbio_library) { create(:pacbio_library) }
  let(:pacbio_pool) { create(:pacbio_pool) }
  let(:aliquot) { build(:aliquot, uuid: SecureRandom.uuid, source: pacbio_library, used_by: pacbio_pool, created_at: Time.zone.now, updated_at: Time.zone.now) }
  let(:cache_file_path) { "data/avro_schema_cache/#{schema_subject}_v#{schema_version}.avsc" }
  let(:schema_key) { 'volume_tracking' }
  let(:schema_subject) { 'create-aliquot-in-mlwh' }
  let(:schema_version) { 1 }
  let(:registry_url) { 'http://test-redpanda/subjects/' }
  let(:encoder) { described_class.new(schema_subject, schema_version, registry_url) }
  let(:message_data) { VolumeTracking::MessageBuilder.new(object: aliquot, configuration: Pipelines.pacbio.volume_tracking.avro_schema_version_1).content[schema_key] }

  let(:volume_tracking_avro_response) do
    Rails.root.join('spec/fixtures/volume_tracking_avro_response.json').read
  end

  describe 'encoder' do
    context 'when the schema is not cached' do
      before do
        allow(Rails.logger).to receive(:debug).and_call_original
        stub_request(:get, "#{registry_url}#{schema_subject}/versions/#{schema_version}")
          .to_return(status: 200, body: volume_tracking_avro_response, headers: {})
      end

      it 'fetches schema from registry' do
        FileUtils.rm_f(cache_file_path)
        expect(Rails.logger).to receive(:debug) do |&block|
          expect(block.call).to eq("Fetching and caching schema for #{schema_subject} v#{schema_version}")
        end
        encoder.encode_message(message_data)
      end

      it 'creates a cache file' do
        expect(File).to exist(cache_file_path)
      end
    end

    context 'when the schema cannot be fetched' do
      before do
        # Mock HTTP requests to the schema registry
        stub_request(:get, "#{registry_url}#{schema_subject}/versions/#{schema_version}")
          .to_return(status: 404, body: '', headers: {})
      end

      it 'raises an error' do
        expect { export_job.get_message_schema(schema_subject, schema_version) }.to raise_error(StandardError)
      end
    end

    context 'when the schema is cached' do
      before do
        allow(Rails.logger).to receive(:debug).and_call_original # Ensure other debug calls work as expected
      end

      it 'uses schema from cache' do
        expect(Rails.logger).to receive(:debug) do |&block|
          expect(block.call).to eq("Using cached schema for #{schema_subject} v#{schema_version}")
        end
        encoder.encode_message(message_data)
      end
    end

    context 'encodes message' do
      before do
        stub_request(:get, "#{registry_url}#{schema_subject}/versions/#{schema_version}")
          .to_return(status: 200, body: volume_tracking_avro_response, headers: {})
      end

      it 'encodes message' do
        expect { encoder.encode_message(message_data) }.not_to raise_error
        expect(encoder.encode_message(message_data)).to be_truthy
      end

      it 'fails encoding' do
        library = create(:pacbio_library)
        aliquot = build(:aliquot, used_by: pacbio_library, source: library, created_at: '')
        message_data = VolumeTracking::MessageBuilder.new(object: aliquot, configuration: Pipelines.pacbio.volume_tracking.avro_schema_version_1).content[schema_key]

        # Assuming `encode_message` raises an error on failure
        expect { encoder.encode_message(message_data) }.to raise_error(Avro::IO::AvroTypeError)
      end
    end

    context 'when the schema response cannot be parsed' do
      before do
        stub_request(:get, "#{registry_url}#{schema_subject}/versions/#{schema_version}")
          .to_return(status: 200, body: volume_tracking_avro_response, headers: {})
        # Mock the file existence check to force fetching from the registry
        allow(File).to receive(:exist?).and_return(false)
        # Mock the response from the registry to return invalid JSON
        allow(encoder).to receive(:fetch_response).and_return(double('Response', body: 'invalid json')) # rubocop:disable RSpec/VerifiedDoubles
      end

      it 'logs an error and raises Standard Error' do
        expect(Rails.logger).to receive(:error).with("Error validating volume tracking message: <unexpected character: 'invalid json'>")
        expect { encoder.encode_message(message_data) }.to raise_error(StandardError)
      end
    end
  end
end
