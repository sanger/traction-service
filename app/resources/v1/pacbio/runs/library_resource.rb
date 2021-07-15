# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      class LibraryResource < JSONAPI::Resource
        model_name 'Pacbio::Library'
        attributes :state, :volume, :concentration, :template_prep_kit_box_barcode,
                   :fragment_size, :created_at, :deactivated_at, :source_identifier
      end
    end
  end
end
