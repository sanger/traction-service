# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {Pacbio::Run}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    # This resource represents a Pacbio Run and can return all runs, a single run or multiple
    # runs along with their relationships.
    # It can also create and update runs and their nested relationships
    # via the plates_attributes parameter. These actions also publish run messages to the warehouse.
    #
    # ## Filters:
    #
    # * name
    # * state
    #
    # ## Primary relationships:
    #
    # * plates {V1::Pacbio::PlateResource}
    # * smrt_link_version {V1::Pacbio::SmrtLinkVersionResource}
    #
    # ## Relationship trees:
    #
    # * plates.wells.used_aliquots
    # * smrt_link_version.smrt_link_option_versions
    #
    # @example
    #   curl -X GET http://localhost:3000/v1/pacbio/runs/1
    #   curl -X GET http://localhost:3000/v1/pacbio/runs/
    #   curl -X GET http://localhost:3000/v1/pacbio/runs/1?include=plates.wells.used_aliquots,smrt_link_version
    #
    #   http://localhost:3000/v1/pacbio/runs?filter[name]=TRACTION-RUN-1
    #   http://localhost:3000/v1/pacbio/runs?filter[state]=pending
    #
    class RunResource < JSONAPI::Resource
      model_name 'Pacbio::Run'

      # @!attribute [rw] name
      #   @return [String] the name of the run
      # @!attribute [rw] dna_control_complex_box_barcode
      #   @return [String] the barcode of the DNA control complex box
      # @!attribute [rw] system_name
      #   @return [String] the name of the system
      # @!attribute [rw] created_at
      #   @return [String] the creation time of the run
      # @!attribute [rw] state
      #   @return [String] the state of the run

      # @!attribute [rw] pacbio_smrt_link_version_id
      #   @return [Integer] the ID of the PacBio SMRT Link version
      # @!attribute [rw] plates_attributes
      #   @return [Array<Hash>] the attributes of the plates
      # @!attribute [r] adaptive_loading
      #   @return [Boolean] whether adaptive loading is used
      # @!attribute [r] sequencing_kit_box_barcodes
      #   @return [Array<String>] the barcodes of the sequencing kits
      attributes :name, :dna_control_complex_box_barcode,
                 :system_name, :created_at, :state,
                 :pacbio_smrt_link_version_id, :plates_attributes,
                 :adaptive_loading, :sequencing_kit_box_barcodes,
                 :annotations_attributes

      # @!attribute [r] barcodes_and_concentrations
      #   @return [String] the barcodes and concentrations of the run
      attribute :barcodes_and_concentrations, readonly: true

      has_many :plates, foreign_key_on: :related, foreign_key: 'pacbio_run_id',
                        class_name: 'Runs::Plate'

      has_one :smrt_link_version, foreign_key: 'pacbio_smrt_link_version_id'

      has_many :annotations, class_name: 'Runs::Annotation', foreign_key_on: :related

      filters :name, :state

      paginator :paged

      # Well parameters that are permitted for the plates_attributes
      PERMITTED_WELL_PARAMETERS = %i[
        id row column comment
      ].concat(Rails.configuration.pacbio_smrt_link_versions.options.keys).freeze

      after_save :publish_messages

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      # JSON API Resources builds up a representation of the relationships on
      # a give resource. Whilst doing to it asks the associated resource for
      # its type, before using this method on the parent resource to attempt
      # to look up the model. Unfortunately this results in V1::Pacbio::PlateResource
      # by default.
      # We should probably consider renaming Runs::Plate to something like Runs::PacBioPlate
      # thereby updating the type. However this will also need updates to routes,
      # and the front end.
      # i.e. this is needed for GET /v1/pacbio/runs?include=plate
      def self.resource_klass_for(type)
        if type == 'plates'
          super('runs/plates')
        elsif type == 'annotations'
          super('runs/annotations')
        else
          super
        end
      end

      def publish_messages
        Messages.publish(@model, Pipelines.pacbio.message)
        Emq::Publisher.publish(@model.aliquots_to_publish_on_run, Pipelines.pacbio,
                               'volume_tracking')
      end

      def self.creatable_fields(context)
        super - %i[adaptive_loading sequencing_kit_box_barcodes]
      end

      def self.updatable_fields(context)
        super - %i[adaptive_loading sequencing_kit_box_barcodes]
      end

      private

      def annotations_attributes=(annotations_parameters)
        @model.annotations_attributes = annotations_parameters.map do |annotation|
          annotation.permit(:comment, :user, :annotation_type_id)
        end
      end

      def plates_attributes=(plates_parameters)
        @model.plates_attributes = plates_parameters.map { |plate| permit_plate_params(plate) }
      end

      def permit_plate_params(plate)
        plate.permit(
          :id,
          :sequencing_kit_box_barcode,
          :plate_number,
          wells_attributes: [:_destroy, PERMITTED_WELL_PARAMETERS, permitted_used_aliquots]
        )
      end

      def permitted_used_aliquots
        { used_aliquots_attributes: %i[
          id source_id source_type volume concentration
          aliquot_type template_prep_kit_box_barcode _destroy
        ] }
      end
    end
  end
end
