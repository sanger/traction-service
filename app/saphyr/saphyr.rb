# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  def self.table_name_prefix
    'saphyr_'
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

  def self.request_factory(sample:, container:, request_attributes:)
    ::Request.new(
      sample: sample,
      requestable: Saphyr::Request.new(
        container: container,
        **request_attributes.slice(*self.request_attributes)
      )
    )
  end
end
