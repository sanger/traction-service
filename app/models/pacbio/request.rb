# frozen_string_literal: true

module Pacbio
  # Pacbio::Request
  # A request can have many libraries
  class Request < ApplicationRecord
    include TubeMaterial
    include WellMaterial
    include Aliquotable

    attribute :cost_code, default: -> { Rails.application.config.pacbio_request_cost_code }

    has_many :libraries, class_name: 'Pacbio::Library', dependent: :nullify,
                         foreign_key: :pacbio_request_id, inverse_of: :request
    has_one :plate, through: :well, class_name: '::Plate'
    has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
    has_one :sample, through: :request

    delegate :name, to: :sample, prefix: :sample
    delegate :species, to: :sample, prefix: :sample

    validates :external_study_id, uuid: true

    validates(*Pacbio.required_request_attributes, presence: true)

    after_create :generate_primary_aliquot

    # While this aliquot is not volume tracked we can just create it with empty data
    def generate_primary_aliquot
      Aliquot.create!(
        source: self,
        aliquot_type: :primary,
        state: :created
      )
    end

    def container
      tube || well
    end

    def source_identifier
      container&.identifier
    end

    def sequencing_plates
      libraries.collect(&:sequencing_plates).flatten.uniq
    end

    # @return [Array] of Runs that the request is used in
    def sequencing_runs
      libraries.collect(&:sequencing_plates).flatten.collect(&:run).uniq
    end
  end
end
