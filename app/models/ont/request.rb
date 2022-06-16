# frozen_string_literal: true

module Ont
  # Ont::Request
  class Request < ApplicationRecord
    include TubeMaterial
    include WellMaterial

    belongs_to :library_type
    belongs_to :data_type

    has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
    has_one :sample, through: :request

    validates :cost_code, presence: true
    validates :number_of_flowcells, numericality: { only_integer: true, greater_than: 0 }
    validates :external_study_id, uuid: true, presence: true

    validates :library_type, pipeline: :ont
    validates :data_type, pipeline: :ont
  end
end
