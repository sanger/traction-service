# frozen_string_literal: true

# SourceIdentifierFilterable
#
# This module provides functionality for filtering records based on source identifiers.
# A source identifier can be a plate barcode, tube barcode, or a combination of plate barcode
# and well position.
# Models that include this module will have methods to filter records using these identifiers.
#
# ## Methods:
#
# * apply_source_identifier_filter(records, value, plate_join: :plate,
#                                  tube_join: :tube, well_join: :well)
#   - Filters the given records based on the provided source identifiers.
#   - Parameters:
#     - records: The ActiveRecord relation to filter.
#     - value: An array of source identifiers to filter by.
#     - plate_join: The association name for joining with the plate table (default: :plate).
#     - tube_join: The association name for joining with the tube table (default: :tube).
#     - well_join: The association name for joining with the well table (default: :well).
#
# ## Example Usage:
#
#   class MyModel < ApplicationRecord
#     include SourceIdentifierFilterable
#   end
#
#   records = MyModel.all
#   source_identifiers = ['PLATE123', 'TUBE456', 'PLATE789:A1']
#   filtered_records = MyModel.apply_source_identifier_filter(records, source_identifiers)
#
#   # Custom join associations
#   filtered_records = MyModel.apply_source_identifier_filter(records, source_identifiers,
#                                                             plate_join: :source_plate,
#                                                             tube_join: :source_tube)
#
module SourceIdentifierFilterable
  extend ActiveSupport::Concern

  class_methods do # rubocop:disable Metrics/BlockLength
    def apply_source_identifier_filter(records, value, # rubocop:disable Metrics/MethodLength,Metrics/PerceivedComplexity
                                       plate_join: :plate, tube_join: :tube, well_join: :well)
      rec_ids = []
      value.each do |val|
        # Check if the source identifier contains a colon
        if val.include?(':')
          # Split the source identifier into plate and well
          plate, well = val.split(':')
          # Filter records based on plate and well
          if plate.present?
            filtered_recs = records.joins(plate_join).where(plate_join => { barcode: plate })
            if well.present?
              filtered_recs = filtered_recs.joins(well_join).where(well_join => { position: well })
            end
          else
            Rails.logger.warn("Malformed source identifier: '#{val}'. Plate part is missing.")
            next
          end
        else
          filtered_recs = records.joins(plate_join).where(plate_join => { barcode: val })
          if filtered_recs.empty?
            filtered_recs = records.joins(tube_join).where(tube_join => { barcode: val })
          end
        end
        # Add the filtered record ids to the list
        rec_ids.concat(filtered_recs.pluck(:id))
      rescue StandardError => e
        Rails.logger.warn("Invalid source identifier: #{val}, error: #{e.message}")
      end
      records.where(id: rec_ids)
    end
  end
end
