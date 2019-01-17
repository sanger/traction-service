module V1
  class LibraryResource < JSONAPI::Resource
    attributes :state
    has_one :sample, always_include_linkage_data: true
    has_one :tube, always_include_linkage_data: true
  end
end
