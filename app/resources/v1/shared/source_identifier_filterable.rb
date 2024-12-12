# frozen_string_literal: true

module V1::Shared
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

    class_methods do
      def apply_source_identifier_filter(records, value, plate_join: :plate, tube_join: :tube,
                                         well_join: :well)
        record_ids = []
        value.each do |val|
          filtered_records = V1::Shared::SourceIdentifierFilterable.filter_by_identifier(records,
                                                                                         val,
                                                                                         plate_join,
                                                                                         tube_join,
                                                                                         well_join)
          record_ids.concat(filtered_records.pluck(:id)) if filtered_records
        rescue StandardError => e
          Rails.logger.warn("Invalid source identifier: #{val}, error: #{e.message}")
        end
        records.where(id: record_ids)
      end
    end

    module_function

    # Filters the given records based on the provided value format
    def filter_by_identifier(records, value, plate_join, tube_join, well_join)
      if value.include?(':')
        filter_by_plate_and_well(records, value, plate_join, well_join)
      else
        filter_by_plate_or_tube(records, value, plate_join, tube_join)
      end
    end

    # Filters records by plate and well position
    def filter_by_plate_and_well(records, value, plate_join, well_join)
      plate, well = value.split(':')
      if plate.present?
        filtered_records = records.joins(plate_join).where(plate_join => { barcode: plate })
        if well.present?
          filtered_records = filtered_records.joins(well_join)
                                             .where(well_join => { position: well })
        end
        filtered_records
      else
        Rails.logger.warn("Malformed source identifier: '#{value}'. Plate part is missing.")
        nil
      end
    end

    # Filters records by plate or tube barcode
    def filter_by_plate_or_tube(records, value, plate_join, tube_join)
      filtered_records = records.joins(plate_join).where(plate_join => { barcode: value })
      if filtered_records.empty?
        filtered_records = records.joins(tube_join).where(tube_join => { barcode: value })
      end
      filtered_records
    end
  end
end
