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

      well_options.map.with_index do |attributes, _i|
        # Assuming attributes['pools'] and the given pool id's exists
        # If not, there is a problem and throw a 5**
        pools = attributes['pools'].map { |pool_id| Pacbio::Pool.find(pool_id) }

        if attributes[:id]
          attributes['pools'] = pools
          wells.find(attributes[:id]).assign_attributes(attributes)
        else
          attributes['pools'] = pools if attributes['pools']
          wells.build(attributes)
        end
      end
    end

    def delete_removed_wells(well_options)
      options_ids = well_options.pluck(:id).compact

      # This loop here preloads the wells
      # This ensures the wells.find(attributes[:id]) block
      # in well_attributes=
      # is successful because wells have been preloaded
      # Otherwise, access wells[i] before calling find
      wells.each do |well|
        wells.delete(well) if options_ids.exclude? well.id
      end
    end

    # DPL-433 Could this be removed?
    def all_wells_have_pools?
      return false if wells.empty?

      wells.all?(&:pools?)
    end
  end
end
