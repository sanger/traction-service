# frozen_string_literal: true

module Pacbio
  # Pacbio::RequestLibrary
  class RequestLibrary < ApplicationRecord
    belongs_to :request, class_name: 'Pacbio::Request', foreign_key: :pacbio_request_id,
                         inverse_of: :request_libraries
    belongs_to :library, class_name: 'Pacbio::Library', foreign_key: :pacbio_library_id,
                         inverse_of: :request_libraries
    belongs_to :tag, class_name: '::Tag', foreign_key: :tag_id, inverse_of: false

    delegate :sample_name, to: :request
    delegate :oligo, :group_id, :set_name, to: :tag, prefix: :tag
  end
end
