# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # Provides a JSON:API resource for the Pacbio::Well model.
      #
      # == Description
      #
      # WellResource exposes the attributes and relationships of a Pacbio Well,
      # which represents a single well on a Pacbio plate. It allows clients to
      # retrieve, create, and update wells, including their associated libraries,
      # pools, used aliquots, and annotations.
      #
      # ## Primary relationships:
      #
      # * +used_aliquots+   - Has many used aliquots (Aliquot)
      # * +libraries+       - Has many libraries (Pacbio::Library)
      # * +pools+           - Has many pools (Pacbio::Pool)
      # * +annotations+     - Has many annotations (Annotation)
      #
      # @Example Usage
      #
      #   # Get a single well
      #   curl -X GET http://localhost:3000/v1/pacbio/runs/wells/1
      #
      #   # Get all wells for a plate
      #   curl -X GET "http://localhost:3000/v1/pacbio/runs/wells?filter[pacbio_plate_id]=1"
      #
      #   # Get a well with related libraries and annotations
      #   curl -X GET "http://localhost:3000/v1/pacbio/runs/wells/1?include=libraries,annotations"
      #
      #   # Create a well with nested annotations
      #   curl -X POST http://localhost:3000/v1/pacbio/runs/wells \
      #     -H "Content-Type: application/vnd.api+json" \
      #     -d '{
      #           "data": {
      #             "type": "wells",
      #             "attributes": {
      #               "row": "A",
      #               "column": "1",
      #               "pacbio_plate_id": 1,
      #               "annotations_attributes": [
      #                 {
      #                   "comment": "QC passed",
      #                   "user": "jsmith",
      #                   "annotation_type_id": 1
      #                 }
      #               ]
      #             }
      #           }
      #         }'
      #
      # @note Access this resource via the `/v1/pacbio/runs/wells` endpoint.
      #
      class WellResource < JSONAPI::Resource
        model_name 'Pacbio::Well'

        # @!attribute [rw] row
        #   @return [String] the row of the well
        # @!attribute [rw] column
        #   @return [String] the column of the well
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
        # @!attribute [rw] use_adaptive_loading
        #   @return [Boolean] whether to use adaptive loading
        # @!attribute [rw] full_resolution_base_qual
        #   @return [Boolean] whether to apply full resolution base qual
        attributes :row, :column, :pacbio_plate_id, :position,
                   :annotations_attributes,
                   *Rails.configuration.pacbio_smrt_link_versions.options.keys

        has_many :used_aliquots, class_name: 'Aliquot', relation_name: :used_aliquots
        has_many :libraries
        has_many :pools
        has_many :annotations, class_name: 'Annotation', foreign_key_on: :related

        # JSON API Resources builds up a representation of the relationships on
        # a give resource. Whilst doing to it asks the associated resource for
        # its type, before using this method on the parent resource to attempt
        # to look up the model. Unfortunately this is forced to use the same
        # namespace by default.
        def self.resource_klass_for(type)
          case type.downcase.pluralize
          when 'libraries' then Pacbio::LibraryResource
          when 'pools' then Pacbio::PoolResource
          when 'annotations' then Pacbio::Runs::AnnotationResource
          else
            super
          end
        end

        private

        def annotations_attributes=(annotations_parameters)
          @model.annotations_attributes = annotations_parameters.map do |annotation|
            annotation.permit(:comment, :user, :annotation_type_id)
          end
        end
      end
    end
  end
end
