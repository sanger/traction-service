# frozen_string_literal: true

require 'pacbio/pacbio'

module Pacbio
  # Pacbio::Request
  # A request can have many libraries
  class Request < ApplicationRecord
    include Pipelines::Requestor::Model
    attribute :cost_code, default: Rails.application.config.pacbio_request_cost_code

    has_many :libraries, class_name: 'Pacbio::Library', dependent: :nullify,
                         foreign_key: :pacbio_request_id, inverse_of: :request
    has_one :plate, through: :well, class_name: '::Plate'
  end
end
