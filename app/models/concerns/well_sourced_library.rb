# frozen_string_literal: true

# Include in a library record to provide a #source_identifier method
# based on libraries with a single source well
module WellSourcedLibrary
  extend ActiveSupport::Concern

  included do
    has_one :source_container_material, through: :request, source: :container_material
    # Because its a polymorphic association, we need to be explicit about what
    # we'll get back. This means we need to specify both source_type and
    # class_name. We specify both, as otherwise rails struggles to work out if
    # we want '::Well' or '<Namespace>::Well' and either ends up using the wrong
    # table, or expects to see '::Well' in the container_type column
    has_one :source_well, through: :source_container_material, source: :container,
                          source_type: 'Well', class_name: '::Well'
  end

  # Identifies the plate and well from which the library was created
  # Typically in the format: DN123:A1.
  #
  # @return [String] Identifies source plate and wells. eg. 'DN123:A1'
  #
  def source_identifier
    source_well&.identifier
  end
end
