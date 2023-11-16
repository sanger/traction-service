# frozen_string_literal: true

module Saphyr
  # Saphyr::Request
  # A saphyr request is a material
  # A saphyr request can have many libraries
  # A saphyr request can have one sample
  class Request < ApplicationRecord
    include TubeMaterial
    include WellMaterial

    has_many :libraries, class_name: 'Saphyr::Library', foreign_key: :saphyr_request_id,
                         dependent: :nullify, inverse_of: :request

    has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
    has_one :sample, through: :request

    delegate :name, to: :sample, prefix: :sample
    delegate :species, to: :sample, prefix: :sample

    validates :external_study_id, uuid: true

    validates(*Saphyr.required_request_attributes, presence: true)

    def container
      tube || well
    end

    def source_identifier
      container&.identifier
    end
  end
end
