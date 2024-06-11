# frozen_string_literal: true

# ONT
module Ont
  def self.table_name_prefix
    'ont_'
  end

  def self.library_attributes
    %i[
      volume concenetration kit_barcode insert_size tag_id
    ]
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

  def self.library_factory(request:, library_attributes:)
    # We need to find the tag_id from the tag_sequence provided
    # TODO: We should take a tag_set here as well as there are duplicate oligos across tagsets
    #
    library_attributes[:tag_id] = Tag.find_by(oligo: library_attributes[:tag_sequence])
    filtered_attributes = library_attributes.slice(*self.library_attributes)

    Ont::Library.new(
      request: request.requestable,
      **filtered_attributes
    )
  end

  def self.request_factory(sample:, container:, request_attributes:, resource_factory:, reception:)
    ::Request.new(
      sample:,
      reception:,
      requestable: Ont::Request.new(
        container:,
        **request_attributes.slice(*self.request_attributes - associated_request_attributes),
        library_type: resource_factory.library_type_for(request_attributes),
        data_type: resource_factory.data_type_for(request_attributes)
      )
    )
  end
end
