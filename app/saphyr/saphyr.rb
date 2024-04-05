# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  def self.table_name_prefix
    'saphyr_'
  end

  def self.library_attributes
    raise StandardError, 'Unsupported' # Only Pacbio is supported at the moment
  end

  def self.request_attributes
    [
      :external_study_id
    ]
  end

  def self.required_request_attributes
    [
      :external_study_id
    ]
  end

  # Parameters would be request: and library_attributes: if this was supported.
  def self.library_factory(*)
    raise StandardError, 'Unsupported' # Only Pacbio is supported at the moment
  end

  # We have this argument here for API compatibility
  # rubocop:disable Lint/UnusedMethodArgument
  def self.request_factory(sample:, container:, request_attributes:, resource_factory:, reception:)
    ::Request.new(
      sample:,
      reception:,
      requestable: Saphyr::Request.new(
        container:,
        **request_attributes.slice(*self.request_attributes)
      )
    )
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
