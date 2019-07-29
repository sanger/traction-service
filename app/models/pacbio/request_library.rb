# frozen_string_literal: true

module Pacbio
  class RequestLibrary < ApplicationRecord
    belongs_to :request, class_name: 'Pacbio::Request', foreign_key: :pacbio_request_id
    belongs_to :library, class_name: 'Pacbio::Library', foreign_key: :pacbio_library_id
    belongs_to :tag, class_name: '::Tag', foreign_key: :tag_id
  end
end
