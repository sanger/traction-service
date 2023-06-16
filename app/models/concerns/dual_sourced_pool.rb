# frozen_string_literal: true

# Include in a pool record to provide a #source_identifier method
# based on source plates.
module DualSourcedPool
  extend ActiveSupport::Concern

  included do
    has_many :container_materials, through: :requests
    # Because its a polymorphic association, we need to be explicit about what
    # we'll get back. This means we need to specify both source_type and
    # class_name. We specify both, as otherwise rails struggles to work out if
    # we want '::Well' or '<Namespace>::Well' and either ends up using the wrong
    # table, or expects to see '::Well' in the container_type column
    has_many :source_wells, through: :container_materials, source: :container,
                            source_type: 'Well', class_name: '::Well'
    has_many :source_tubes, through: :container_materials, source: :container,
                            source_type: 'Tube', class_name: '::Tube'
  end

  # Identifies the plate and wells from which the pool was created
  # Typically in the format: DN123:A1-D1.
  # In the unlikely event we have multiple plates, will include them all
  # @note Assumes 96 well plates. formatted_range can take a second argument
  # of plate_size if this ever changes.
  #
  # @return [String] Identifies source plate and wells. eg. 'DN123:A1-D1
  #
  def source_identifier
    formatted_wells = wells_grouped_by_container.map do |plate, wells|
      well_range = plate.formatted_range(wells.pluck(:position))
      "#{plate.barcode}:#{well_range}"
    end.join(',')
    formatted_tubes = source_tubes.pluck(:barcode).join(',')
    # Combines the two outputs checking neither are empty
    [formatted_wells, formatted_tubes].filter(&:present?).join(',')
  end

  private

  def wells_grouped_by_container
    source_wells.group_by(&:plate)
  end
end
