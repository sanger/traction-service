# frozen_string_literal: true

# Validator for ensuring use_adaptive_loading is consistent across all wells
class UseAdaptiveLoadingValidator < ActiveModel::Validator
  # @param [ActiveRecord::Base] record
  def validate(record)
    return if record.use_adaptive_loading == record.run.wells.first.use_adaptive_loading

    record.errors.add(:base, "well #{record.position} has a differing 'Use Adaptive Loading' value")
  end
end
