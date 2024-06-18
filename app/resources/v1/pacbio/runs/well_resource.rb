# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # WellResource
      class WellResource < JSONAPI::Resource
        model_name 'Pacbio::Well'

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
