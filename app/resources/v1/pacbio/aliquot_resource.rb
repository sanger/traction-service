# frozen_string_literal: true

module V1
  module Pacbio
    # AliquotResource
    class AliquotResource < JSONAPI::Resource
      model_name '::Aliquot'

      attributes :aliquot_type, :source, :used_by, :state,
                 :volume, :concentration, :insert_size, :template_prep_kit_box_barcode, :tag_id
    end
  end
end
