# frozen_string_literal: true

module V1
  # ChipResource
  class ChipResource < JSONAPI::Resource
    attributes :barcode
    has_many :flowcells, foreign_key_on: :related

    has_one :saphyr_run, class_name: 'Saphyr::Run', foreign_key: 'saphyr_run_id'
  end
end
