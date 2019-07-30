# frozen_string_literal: true

module Pacbio
  # Pacbio::RequestLibrary
  class RequestLibrary < ApplicationRecord
    belongs_to :request, class_name: 'Pacbio::Request', foreign_key: :pacbio_request_id
    belongs_to :library, class_name: 'Pacbio::Library', foreign_key: :pacbio_library_id
    belongs_to :tag, class_name: '::Tag', foreign_key: :tag_id

    delegate :sample_name, to: :request
    delegate :oligo, :group_id, :set_name, to: :tag, prefix: :tag
  end
end
