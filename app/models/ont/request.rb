# frozen_string_literal: true

module Ont
  # Ont::Request
  class Request < ApplicationRecord
    include TubeMaterial
    include WellMaterial

    belongs_to :library_type
    belongs_to :data_type

    has_many :libraries, class_name: 'Ont::Library', dependent: :nullify,
                         foreign_key: :ont_request_id, inverse_of: :request
    has_one :plate, through: :well, class_name: '::Plate'
    has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
    has_one :sample, through: :request
    delegate :name, to: :sample, prefix: :sample

    validates :cost_code, presence: true
    validates :number_of_flowcells, numericality: { only_integer: true, greater_than: 0 }
    validates :external_study_id, uuid: true, presence: true

    validates :library_type, pipeline: :ont
    validates :data_type, pipeline: :ont

    def container
      tube || well
    end

    def source_identifier
      container&.identifier
    end
  end
end
