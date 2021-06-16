# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # WellLibraryResource
      class WellLibraryResource < JSONAPI::Resource
        model_name 'Pacbio::WellLibrary'

        has_one :tube

        def self.records_for_populate(*_args)
          super.preload(library: :tube)
        end
      end
    end
  end
end
