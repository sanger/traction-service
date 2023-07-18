# frozen_string_literal: true

# Validates that attribute belongs to the configured pipeline
# @example
#   validates :library_type, pipeline: :ont
# Requires that the associated attribute responds to
class PipelineValidator < ActiveModel::EachValidator
  def initialize(options)
    super

    # We'll give some helpful errors if we configure it wrong
    raise ArgumentError, 'No target pipeline specified' if expected.nil?
    raise ArgumentError, "#{expected} is not a recognised pipeline" unless valid_pipeline?
  end

  def validate_each(record, attribute, value)
    return if value.blank?

    actual = value.pipeline
    return if actual == expected.to_s

    record.errors.add(attribute, :pipeline_invalid, expected:, actual:)
  end

  private

  def expected
    options[:with]
  end

  def valid_pipeline?
    Pipelines::NAMES.key?(expected)
  end
end
