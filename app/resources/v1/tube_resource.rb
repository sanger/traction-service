module V1
  class TubeResource < JSONAPI::Resource
    attributes :barcode
    has_one :library, foreign_key_on: :related, always_include_linkage_data: true
  end
end
