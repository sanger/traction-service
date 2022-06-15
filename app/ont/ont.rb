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

  def self.request_factory(sample:, container:, request_attributes:)
    ::Request.new(
      sample: sample,
      requestable: Ont::Request.new(
        container: container,
        **request_attributes.slice(*self.request_attributes - associated_request_attributes),
        library_type: LibraryType.find_by(name: request_attributes[:library_type]),
        data_type: DataType.find_by(name: request_attributes[:data_type])
      )
    )
  end
end
