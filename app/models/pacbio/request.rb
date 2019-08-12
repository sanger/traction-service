# frozen_string_literal: true

require 'pacbio/pacbio'

module Pacbio
  # Pacbio::Request
  class Request < ApplicationRecord
    include Pipelines::Requestor::Model

    has_many :request_libraries, class_name: 'Pacbio::RequestLibrary',
                                 foreign_key: :pacbio_request_id, dependent: :nullify,
                                 inverse_of: :request
    has_many :libraries, class_name: 'Pacbio::Library', through: :request_libraries,
                         dependent: :nullify
  end
end
