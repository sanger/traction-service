# frozen_string_literal: true

# validate SmrtLinkOptions by version
# This allows more flexible modification of fields by version
class SmrtLinkOptionsValidator < ActiveModel::Validator
  attr_reader :available_smrt_link_versions, :required_fields_by_version

  def initialize(options)
    super
    @available_smrt_link_versions = options[:available_smrt_link_versions]
    @required_fields_by_version = options[:required_fields_by_version]
  end

  def validate(record)
    # If the version is not present no point validating
    return if record&.run&.smrt_link_version.blank?

    # If the version is not valid no point validating
    smrt_link_version = record.run.smrt_link_version
    return unless available_smrt_link_versions.include?(smrt_link_version)

    # match the version and return the fields for that version
    # check whether the value is a valid value
    required_fields_by_version[smrt_link_version].each do |field, valid_options|
      next if valid_options.include? record.smrt_link_options[field]

      record.errors.add(field, 'Not a valid value')
    end
  end
end
