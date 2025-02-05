# frozen_string_literal: true

# TubeMaterial -- A material that is contained in a tube.
# This is here to support legacy features of Pacbio
# after Containers were introduced as a concern.
module TubeMaterial
  extend ActiveSupport::Concern
  include Material

  included do
    has_one :tube, through: :container_material, source: :container,
                   source_type: 'Tube', class_name: '::Tube'
  end
end
