module V1
  class SampleResource < JSONAPI::Resource
    attributes :name, :state, :sequencescape_request_id, :species
  end
end
