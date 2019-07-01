# frozen_string_literal: true

module V1
  module Saphyr
    # RunResource
    class RunResource < JSONAPI::Resource
      model_name 'Saphyr::Run'

      attributes :state, :chip_barcode, :created_at, :name

      has_one :chip, foreign_key_on: :related, foreign_key: 'saphyr_run_id'

      def chip_barcode
        @model&.chip&.barcode
      end

      def created_at
        @model.created_at.strftime('%m/%d/%Y %H:%M')
      end

      def self.records(_options = {})
        ::Saphyr::Run.active
      end
    end
  end
end
