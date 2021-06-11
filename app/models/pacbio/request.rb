# frozen_string_literal: true

require 'pacbio/pacbio'

module Pacbio
  # Pacbio::Request
  # A request can have many libraries
  class Request < ApplicationRecord
    include Pipelines::Requestor::Model

    has_many :libraries, class_name: 'Pacbio::Library', dependent: :nullify,
                         foreign_key: :pacbio_request_id, inverse_of: :request
  end
end
