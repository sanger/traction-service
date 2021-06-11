# frozen_string_literal: true

# WellMaterial -- A material that is contained in a well.
module WellMaterial
  extend ActiveSupport::Concern
  include Material

  included do
    has_one :well, through: :container_material, source: :container,
                   source_type: 'Well', class_name: '::Well'
  end
end
