# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  include JSONAPI::ActsAsResourceController
  skip_before_action :verify_authenticity_token

  # Caution: Using this approach for a 'create' action is not strictly JSON API
  # compliant.
  def serialize_array(array)
    {
      data: array.map do |r|
        JSONAPI::ResourceSerializer.new(r.class).object_hash(r, {})
      end
    }
  end

  # Where possible try to use the default json api resources actions, as
  # they will correctly ensure parameters such as include are properly processed
  def serialize_resource(resource)
    { data: JSONAPI::ResourceSerializer.new(resource.class).object_hash(resource, {}) }
  end
end
