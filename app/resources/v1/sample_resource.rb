module V1
  class SampleResource < JSONAPI::Resource
    attributes :name, :state, :sequencescape_request_id, :species
    has_many :libraries, always_include_linkage_data: true
    has_one :tube
  end
end
