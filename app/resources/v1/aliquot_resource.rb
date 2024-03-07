# frozen_string_literal: true

# JSON-API resources wont resolve across namespaces spaces
# so we need the Aliquot resource in the PacBio namespace
module V1
  # AliquotResource
  class AliquotResource < JSONAPI::Resource
    model_name 'Aliquot'
    attributes :aliquot_type, :source_id, :source_type, :used_by_id, :used_by_type, :state,
               :volume, :concentration, :insert_size, :template_prep_kit_box_barcode, :tag_id

    has_one :source, polymorphic: true,
                     polymorphic_types: %w[pacbio/requests pacbio/pools pacbio/libraries]
    has_one :used_by, polymorphic: true,
                      polymorphic_types: %w[pacbio/requests pacbio/pools pacbio/libraries]

    has_one :tag, always_include_optional_linkage_data: true

    # Aliquot polymorphism support
    # This fixes the polymorphic relationships in json-api resources
    # as json-api resources underscores and pluralizes the type
    def self.resource_klass_for(type)
      super(type.underscore.pluralize.gsub('pacbio/', ''))
    end
  end
end
