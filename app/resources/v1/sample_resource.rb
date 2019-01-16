module V1
  class SampleResource < JSONAPI::Resource
    attributes :name, :state, :sequencescape_request_id, :species
    has_many :libraries, always_include_linkage_data: true
  end
end
