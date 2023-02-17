# frozen_string_literal: true

module RequestHelpers
  def json_api_headers
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  #
  # Returns a hash representing the decoded json response
  #
  # @return [Hash] The decoded json
  #
  def json
    ActiveSupport::JSON.decode(response.body)
  end

  #
  # Find a resource record in the provided json
  #
  # @param json [Hash] decoded response object
  # @param id [String, Integer] The ID of the resource to find
  # @param type [String] The resource type to find
  # @param from ['data','included'] Whether to look in the data or included resources
  #
  # @return [Hash] Hash representation of the given resource
  #
  def find_resource(id:, type:, from: 'data', json: self.json)
    find_id_and_type(id:, type:, data: json.fetch(from))
  end

  # Find a resource record in the included section of the provided json
  #
  # @param json [Hash] decoded response object
  # @param id [String, Integer] The ID of the resource to find
  # @param type [String] The resource type to find
  #
  # @return [Hash] Hash representation of the given resource
  #
  def find_included_resource(id:, type:, json: self.json)
    find_resource(id:, type:, from: 'included', json:)
  end

  #
  # Find a resource record in the provided array
  #
  # @param data [Array] Array of resource objects
  # @param id [String, Integer] The ID of the resource to find
  # @param type [String] The resource type to find
  #
  # @return [Hash] Hash representation of the given resource
  #
  def find_id_and_type(data:, id:, type:)
    matching_resource = data.detect do |resource|
      resource.values_at('type', 'id') == [type, id.to_s]
    end

    expect(matching_resource).not_to be_nil, lambda {
      found = data.map { |resource| resource.values_at('type', 'id').join(':') }
      "Could not find #{type}:#{id}. Found #{found.to_sentence}"
    }

    matching_resource
  end
end
