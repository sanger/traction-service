# frozen_string_literal: true

module Pacbio
  # Plate
  class Plate < ApplicationRecord
    include Uuidable

    belongs_to :run, foreign_key: :pacbio_run_id,
                     inverse_of: :plate
    has_many :wells, class_name: 'Pacbio::Well', foreign_key: :pacbio_plate_id,
                     inverse_of: :plate, dependent: :destroy

    accepts_nested_attributes_for :wells

    validates :wells, length: {
      minimum: 1,
      message: :plate_min_wells
    }

    def well_attributes=(well_options)
      # Delete wells if attributes are not given
      delete_removed_wells(well_options)

      create_or_update_wells(well_options)
    end

    def delete_removed_wells(well_options)
      # Here we need to map the json ids to integers to make sure the exclude comparison uses ints
      options_ids = well_options.pluck(:id).compact.map(&:to_i)

      # This loop here preloads the wells
      # This ensures the wells.find(attributes[:id]) block
      # in well_attributes=
      # is successful because wells have been preloaded
      # Otherwise, access wells[i] before calling find
      wells.each do |well|
        wells.delete(well) if options_ids.exclude? well.id
      end
    end

    def create_or_update_wells(well_options)
      well_options.map do |well_attributes|
        # Assuming attributes['pools'] and the given pool id's exists
        # If not, there is a problem and throw a 5**
        pools = well_attributes['pools'].map { |pool_id| Pacbio::Pool.find(pool_id) }
        well_attributes['pools'] = pools

        if well_attributes[:id]
          wells.find(well_attributes[:id]).assign_attributes(well_attributes)
        else
          wells.build(well_attributes)
        end
      end
    end
  end
end
