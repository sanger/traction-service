# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/api/v1/pacbio/run/` endpoint.
    #
    # Provides a JSON:API representation of {Pacbio::Run}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class RunResource < JSONAPI::Resource
      model_name 'Pacbio::Run'

      # @!attribute [rw] name
      #   @return [String] the name of the run
      # @!attribute [rw] dna_control_complex_box_barcode
      #   @return [String] the barcode of the DNA control complex box
      # @!attribute [rw] system_name
      #   @return [String] the name of the system
      # @!attribute [rw] created_at
      #   @return [DateTime] the creation time of the run
      # @!attribute [rw] state
      #   @return [String] the state of the run
      # @!attribute [rw] comments
      #   @return [String] the comments on the run
      # @!attribute [rw] pacbio_smrt_link_version_id
      #   @return [Integer] the ID of the PacBio SMRT Link version
      # @!attribute [rw] plates_attributes
      #   @return [Array<Hash>] the attributes of the plates
      attributes :name, :dna_control_complex_box_barcode,
                 :system_name, :created_at, :state, :comments,
                 :pacbio_smrt_link_version_id, :plates_attributes

      has_many :plates, foreign_key_on: :related, foreign_key: 'pacbio_run_id',
                        class_name: 'Runs::Plate'

      has_one :smrt_link_version, foreign_key: 'pacbio_smrt_link_version_id'

      filters :name, :state

      paginator :paged

      #
      # # A pain. It means we would need to turn this into a method to beat the cop.
      # rubocop:disable Layout/LineLength
      PERMITTED_WELL_PARAMETERS = %i[id
                                     row column
                                     comment].concat(Rails.configuration.pacbio_smrt_link_versions.options.keys).freeze
      # rubocop:enable Layout/LineLength

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
        else
          super
        end
      end

      def publish_messages
        Messages.publish(@model, Pipelines.pacbio.message)
        Emq::Publisher.publish(@model.all_library_aliquots, Pipelines.pacbio, 'volume_tracking')
      end

      private

      def plates_attributes=(plates_parameters) # rubocop:disable Metrics/MethodLength
        @model.plates_attributes = plates_parameters.map do |plate|
          plate.permit(
            :id,
            :sequencing_kit_box_barcode,
            :plate_number,
            wells_attributes: [
              # the following is needed to allow the _destroy parameter which
              # is used to mark wells for destruction
              :_destroy,
              PERMITTED_WELL_PARAMETERS,
              { used_aliquots_attributes: %i[id source_id source_type volume concentration
                                             aliquot_type template_prep_kit_box_barcode _destroy] }
            ]
          )
        end
      end
    end
  end
end
