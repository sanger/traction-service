# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # @todo This documentation does not yet include a detailed description of what this resource represents.
      # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
      # @todo This documentation does not yet include any example usage of the API via cURL or similar.
      #
      # @note Access this resource via the `/api/v1/pacbio/runs/well` endpoint.
      #
      # Provides a JSON:API representation of {Pacbio::Well}.
      #
      # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
      # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
      # for the service implementation of the JSON:API standard.
      class WellResource < JSONAPI::Resource
        model_name 'Pacbio::Well'

        # @!attribute [rw] row
        #   @return [String] the row of the well
        # @!attribute [rw] column
        #   @return [String] the column of the well
        # @!attribute [rw] comment
        #   @return [String] the comment for the well
        # @!attribute [rw] pacbio_plate_id
        #   @return [Integer] the ID of the Pacbio plate
        # @!attribute [rw] position
        #   @return [String] the position of the well
        # @!attribute [rw] ccs_analysis_output
        #   @return [String] the CCS analysis output
        # @!attribute [rw] generate_hifi
        #   @return [Boolean] whether to generate HiFi reads
        # @!attribute [rw] ccs_analysis_output_include_kinetics_information
        #   @return [Boolean] whether to include kinetics information in the CCS analysis output
        # @!attribute [rw] ccs_analysis_output_include_low_quality_reads
        #   @return [Boolean] whether to include low quality reads in the CCS analysis output
        # @!attribute [rw] include_fivemc_calls_in_cpg_motifs
        #   @return [Boolean] whether to include 5mC calls in CpG motifs
        # @!attribute [rw] demultiplex_barcodes
        #   @return [String] the demultiplex barcodes
        # @!attribute [rw] on_plate_loading_concentration
        #   @return [Float] the on plate loading concentration
        # @!attribute [rw] binding_kit_box_barcode
        #   @return [String] the barcode of the binding kit box
        # @!attribute [rw] pre_extension_time
        #   @return [Integer] the pre-extension time
        # @!attribute [rw] loading_target_p1_plus_p2
        #   @return [Float] the loading target (P1 + P2)
        # @!attribute [rw] movie_time
        #   @return [Float] the movie time in hours
        # @!attribute [rw] movie_acquisition_time
        #   @return [Float] the movie acquisition time in hours
        # @!attribute [rw] include_base_kinetics
        #   @return [Boolean] whether to include base kinetics
        # @!attribute [rw] library_concentration
        #   @return [Float] the library concentration in pM
        # @!attribute [rw] polymerase_kit
        #   @return [String] the polymerase kit
        # @!attribute [rw] library_type
        #   @return [String] the library type
        attributes :row, :column, :comment, :pacbio_plate_id, :position,
                   *Rails.configuration.pacbio_smrt_link_versions.options.keys

        has_many :used_aliquots, class_name: 'Aliquot', relation_name: :used_aliquots
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
