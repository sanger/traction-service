# frozen_string_literal: true

require 'net/http' # Add this line to require Net::HTTP
require 'avro'
require 'fileutils'

module Emq
  # This class should be responsible for encoding messages using an Avro schema
  # stored in RedPanda registry
  class Encoder
    attr_reader :schema_config, :validate_obj

    # Initialize the validator with the subject, version and registry URL
    # @param [String] subject the subject of the schema
    # @param [String] version the version of the schema
    # @param [String] registry_url the URL of the schema registry
    def initialize(subject, version, registry_url)
      @subject = subject
      @version = version
      @registry_url = registry_url
    end

    # Encode a message using the schema
    # @param [Hash] message the message to encode
    # @return [String] the encoded message
    def encode_message(message) # rubocop:disable Metrics/MethodLength
      # Create schema the schema to use for encoding
      schema = create_message_schema
      begin
        schema = Avro::Schema.parse(schema)
      rescue Avro::SchemaParseError => e
        Rails.logger.error("Schema parsing error: <#{e.message}>. Schema: #{schema}")
        raise
      end
      stream = StringIO.new
      writer = Avro::IO::DatumWriter.new(schema)
      encoder = Avro::IO::BinaryEncoder.new(stream)
      encoder.write("\xC3\x01") # Avro single-object container file header
      encoder.write([schema.crc_64_avro_fingerprint].pack('Q')) # 8 byte schema fingerprint
      writer.write(message, encoder)
      stream.string
    rescue StandardError => e
      Rails.logger.error("Error validating volume tracking message: <#{e.message}>")
      raise
    end

    private

    # Create the message schema
    # @return [String] the schema for the message
    def create_message_schema
      # Prefer to use the cached schema if it exists.
      cache_file_path = "data/avro_schema_cache/#{@subject}_v#{@version}.avsc"
      if File.exist?(cache_file_path)
        Rails.logger.debug { "Using cached schema for #{@subject} v#{@version}" }
        return File.read(cache_file_path)
      end

      # Default to fetching the schema from the registry and caching it.
      Rails.logger.debug { "Fetching and caching schema for #{@subject} v#{@version}" }
      response = fetch_response("#{@registry_url}#{@subject}/versions/#{@version}")
      resp_json = JSON.parse(response.body)
      schema_str = resp_json['schema']
      # Ensure the directory exists
      FileUtils.mkdir_p(File.dirname(cache_file_path))
      File.write(cache_file_path, schema_str)
      schema_str
    end

    # Fetch the response from the URL
    # @param [String] uri_str the URL to fetch
    # @param [Integer] limit the number of redirects to follow
    # @return [Net::HTTPResponse] the response
    def fetch_response(uri_str, limit = 10)
      raise IOError, 'Too many HTTP redirects' if limit == 0

      response = Net::HTTP.get_response(URI.parse(uri_str))

      case response
      when Net::HTTPSuccess then response
      when Net::HTTPRedirection then fetch_response(response['location'], limit - 1)
      else
        response.error!
      end
    end
  end
end
