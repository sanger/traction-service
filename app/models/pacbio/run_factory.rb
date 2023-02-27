# frozen_string_literal: true

module Pacbio
  # RunFactory
  class RunFactory
    include ActiveModel::Model

    attr_accessor :run, :wells_attributes

    def construct_resources!
      ApplicationRecord.transaction do
        plate = Pacbio::Plate.create!(pacbio_run_id: run.id)

        @wells_attributes.map do |well_attributes|
          well_attributes[:plate] = { id: plate.id }
        end

        @well_factory = WellFactory.new(@wells_attributes)
        @well_factory.save
      end
    end

    def update_resources!
      ApplicationRecord.transaction do
        # Delete wells if attributes are not given
        well_ids = @wells_attributes.pluck(:id).compact
        run.wells.each do |well|
          run.wells.delete(well) if well_ids.exclude? well.id
        end

        @wells_attributes.map do |well_attributes|
          well_attributes[:plate] = { id: run.plate.id }
        end

        @well_factory = WellFactory.new(@wells_attributes)
        @well_factory.save
      end
    end
  end
end
