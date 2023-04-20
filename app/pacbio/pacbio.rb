# frozen_string_literal: true

# Pacbio
module Pacbio
  def self.table_name_prefix
    'pacbio_'
  end

  def self.request_attributes
    %i[
      library_type estimate_of_gb_required number_of_smrt_cells cost_code
      external_study_id
    ]
  end

  def self.sample_attributes
    %i[external_id name species]
  end

  def self.required_request_attributes
    [
      :external_study_id
    ]
  end

  # We have this argument here for API compatibility
  # rubocop:disable Lint/UnusedMethodArgument
  def self.request_factory(sample:, container:, request_attributes:, resource_factory:, reception:)
    ::Request.new(
      sample:,
      reception:,
      requestable: Pacbio::Request.new(
        container:,
        **request_attributes.slice(*self.request_attributes)
      )
    )
  end
  # rubocop:enable Lint/UnusedMethodArgument

  # Valid values for smrt link options. These are used by several tests, but we
  # removed the old Pacbio::SmrtLink::Versions module.
  YES_NO = %w[Yes No].freeze
  TRUE_FALSE = %w[True False].freeze
  GENERATE = ['In SMRT Link', 'On Instrument', 'Do Not Generate'].freeze
end
