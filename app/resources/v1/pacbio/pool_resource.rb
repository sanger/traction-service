# frozen_string_literal: true

module V1
  module Pacbio
    # PoolResource
    class PoolResource < JSONAPI::Resource
      model_name 'Pacbio::Pool'

      has_one :tube
      has_many :libraries

      attributes :volume, :concentration, :template_prep_kit_box_barcode,
                 :fragment_size, :source_identifier, :created_at, :updated_at

      def self.records_for_populate(*_args)
        super.preload(:source_wells)
      end
    end
  end
end
