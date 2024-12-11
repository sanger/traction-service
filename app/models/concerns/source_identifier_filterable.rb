# frozen_string_literal: true

# app/models/concerns/barcode_filterable.rb
module SourceIdentifierFilterable
  extend ActiveSupport::Concern

  class_methods do # rubocop:disable Metrics/BlockLength
    def apply_source_identifier_filter(records, value, # rubocop:disable Metrics/MethodLength,Metrics/PerceivedComplexity
                                       plate_join: :plate, tube_join: :tube, well_join: :well)
      rec_ids = []
      value.each do |val|
        # byebug
        if val.include?(':')
          plate, well = val.split(':')
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
        rec_ids.concat(filtered_recs.pluck(:id))
      rescue StandardError => e
        Rails.logger.warn("Invalid source identifier: #{val}, error: #{e.message}")
      end
      records.where(id: rec_ids)
    end
  end
end
