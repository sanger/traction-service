# frozen_string_literal: true

module V1
  module Pacbio
    # RunResource
    class RunResource < JSONAPI::Resource
      model_name 'Pacbio::Run'

      attributes :name, :sequencing_kit_box_barcode, :dna_control_complex_box_barcode,
                 :system_name, :created_at, :state, :comments, :all_wells_have_pools,
                 :pacbio_smrt_link_version_id

      has_one :plate, foreign_key_on: :related, foreign_key: 'pacbio_run_id',
                      class_name: 'Runs::Plate'

      has_one :smrt_link_version, foreign_key: 'pacbio_smrt_link_version_id'

      filter :name
      paginator :paged

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      def self.records_for_populate(*_args)
        super.preload(plate: {
                        wells: {
                          pools: {
                            libraries: {
                              request: :sample
                            }
                          }
                        }
                      })
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
      def self.resource_klass_for(type)
        if type == 'plates'
          super('runs/plates')
        else
          super
        end
      end
    end
  end
end
