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

  def self.request_factory(sample:, container:, request_attributes:)
    ::Request.new(
      sample: sample,
      requestable: Pacbio::Request.new(
        container: container,
        **request_attributes.slice(*self.request_attributes)
      )
    )
  end
end
