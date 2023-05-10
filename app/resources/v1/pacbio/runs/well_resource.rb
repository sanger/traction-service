# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # WellResource
      class WellResource < JSONAPI::Resource
        model_name 'Pacbio::Well'

        attributes :movie_time, :insert_size, :on_plate_loading_concentration,
                   :row, :column, :pacbio_plate_id, :comment, :generate_hifi,
                   :position, :pre_extension_time, :ccs_analysis_output,
                   :binding_kit_box_barcode, :loading_target_p1_plus_p2,
                   :ccs_analysis_output_include_low_quality_reads,
                   :include_fivemc_calls_in_cpg_motifs,
                   :ccs_analysis_output_include_kinetics_information,
                   :demultiplex_barcodes, :movie_acquisition_time, :include_base_kinetics,
                   :library_concentration, :polymerase_kit

        has_many :libraries
        has_many :pools

        # JSON API Resources builds up a representation of the relationships on
        # a give resource. Whilst doing to it asks the associated resource for
        # its type, before using this method on the parent resource to attempt
        # to look up the model. Unfortunately this is forced to use the same
        # namespace by default.
        def self.resource_klass_for(type)
          case type.downcase.pluralize
          when 'libraries' then Pacbio::LibraryResource
          when 'pools' then Pacbio::PoolResource
          else
            super
          end
        end
      end
    end
  end
end
