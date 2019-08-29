# frozen_string_literal: true

module Pacbio
  # Pacbio::RequestLibrary
  # A request library is the link between a request and a library
  # Each request library signifies which requests belong in each library
  # Each request library must have a tag
  # Each library must have a unique set of tags
  # The tag and sample information is shown as first class
  # information by delegation
  class RequestLibrary < ApplicationRecord
    belongs_to :request, class_name: 'Pacbio::Request', foreign_key: :pacbio_request_id,
                         inverse_of: :request_libraries
    belongs_to :library, class_name: 'Pacbio::Library', foreign_key: :pacbio_library_id,
                         inverse_of: :request_libraries
    # TODO: make this taggable
    belongs_to :tag, class_name: '::Tag', foreign_key: :tag_id, inverse_of: false

    delegate :sample_name, to: :request
    delegate :oligo, :group_id, :set_name, :id, to: :tag, prefix: :tag

    validates :tag, uniqueness: { scope: :library,
                                  message: 'need to be unique within a library' }
  end
end
