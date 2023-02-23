# frozen_string_literal: true

module V1
  module Pacbio
    # RunResource
    class RunResource < JSONAPI::Resource
      model_name 'Pacbio::Run'

      attributes :name, :sequencing_kit_box_barcode, :dna_control_complex_box_barcode,
                 :system_name, :created_at, :state, :comments, :all_wells_have_pools,
                 :pacbio_smrt_link_version_id, :wells_attributes
      has_one :plate, foreign_key_on: :related, foreign_key: 'pacbio_run_id',
                      class_name: 'Runs::Plate'

      has_one :smrt_link_version, foreign_key: 'pacbio_smrt_link_version_id'

      # Todo
      # Currently no tests for the below
      # filters :name, :state

      paginator :paged

      # Todo
      # Currently no tests for the below
      # def self.default_sort
      #   [{ field: 'created_at', direction: :desc }]
      # end

      after_create :construct_resources!

      def fetchable_fields
        super - [:wells_attributes]
      end

      def construct_resources!
        @model.construct_resources!
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def all_wells_have_pools
        @model.all_wells_have_pools?
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

      private

      def wells_attributes=(wells_parameters)
        raise ArgumentError unless wells_parameters.is_a?(Array)

        @model.wells_attributes = wells_parameters.map do |well|
          well.permit(permitted_wells_attributes, pools: [:id])
              .to_h
              .with_indifferent_access
        end
      end

      # Todo
      # Refactor
      def permitted_wells_attributes
        %i[row column ccs_analysis_output generate_hifi
           ccs_analysis_output_include_low_quality_reads
           include_fivemc_calls_in_cpg_motifs
           ccs_analysis_output_include_kinetics_information
           demultiplex_barcodes on_plate_loading_concentration
           binding_kit_box_barcode pre_extension_time
           loading_target_p1_plus_p2 movie_time]
      end
    end
  end
end
