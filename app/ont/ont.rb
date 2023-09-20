# frozen_string_literal: true

# ONT
module Ont
  def self.table_name_prefix
    'ont_'
  end

  def self.request_attributes
    %i[
      library_type data_type cost_code external_study_id number_of_flowcells
    ]
  end

  def self.associated_request_attributes
    %i[library_type data_type]
  end

  def self.direct_request_attributes
    request_attributes - associated_request_attributes
  end

  def self.request_factory(sample:, container:, request_attributes:, resource_factory:, reception:)
    dt = DataType.find_by(name: request_attributes[:data_type]) || nil
    ::Request.new(
      sample:,
      reception:,
      requestable: Ont::Request.new(
        container:,
        **request_attributes.slice(*self.request_attributes - associated_request_attributes),
        library_type: resource_factory.library_type_for(request_attributes),
        data_type: dt
      )
    )
  end
end
