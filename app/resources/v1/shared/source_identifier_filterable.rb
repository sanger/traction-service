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
  # * apply_source_identifier_filter(records, value, joins: { plate: :plate, tube: :tube,
  #                                                           well: :well })
  #   - Filters the given records based on the provided source identifiers.
  #   - Parameters:
  #     - records: The ActiveRecord relation to filter.
  #     - value: An array of source identifiers to filter by.
  #     - joins: A hash of join associations with default values.
  #       - plate: The association name for joining with the plate table (default: :plate).
  #       - tube: The association name for joining with the tube table (default: :tube).
  #       - well: The association name for joining with the well table (default: :well).
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
  #                                                             joins: { plate: :source_plate,
  #                                                                      tube: :source_tube,
  #                                                                      well: :source_well })
  #
  module SourceIdentifierFilterable
    extend ActiveSupport::Concern

    class_methods do
      def apply_source_identifier_filter(records, value,
                                         joins: { plate: :plate, tube: :tube, well: :well })
        record_ids = value.flat_map do |val|
          filter_values(records, val, joins)
        rescue StandardError => e
          Rails.logger.warn("Invalid source identifier: #{val}, error: #{e.message}")
          []
        end
        records.where(id: record_ids)
      end

      private

      # Filters the records based on the given value and joins.
      #
      # @param records [ActiveRecord::Relation] The ActiveRecord relation to filter.
      # @param value [String] The source identifier to filter by.
      # @param joins [Hash] The hash of join associations.
      # @return [Array<Integer>] The array of record IDs.
      def filter_values(records, value, joins)
        barcode, well = value.split(':')
        # The conditions hash is used to filter the records based on the source identifier.
        # The structure of the conditions hash is as follows:
        # Each entry in inner conditions (e.g plate, well) will be applied consecutively
        # and incrementally, thereby the result of each inner condition will be used as
        # the input for the next condition.
        # The final result will be the concatenation of all outer conditions
        # (eg plate_entry,tube_entry).
        conditions = { plate_entry: { plate: { barcode: barcode }, well: { position: well } },
                       tube_entry: { tube: { barcode: barcode } } }
        # Traverse through the conditions hash and apply the filters
        record_array = conditions.each_with_object([]) do |(_key, condition_val), array|
          # Start filtering records going through inner conditions using reduce to apply
          # each condition incrementally
          result = condition_val.reduce(records) do |res, (inner_key, inner_condition)|
            next res if inner_condition.values.first.blank?

            join = joins[inner_key]
            res.joins(join).where(join => inner_condition) # Progressive joins and filtering
          end
          array.concat(result) if result.any?
        end
        record_array.pluck(:id)
      end
    end
  end
end
