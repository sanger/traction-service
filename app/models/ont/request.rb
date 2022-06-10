# frozen_string_literal: true

module Ont
  # Ont::Request
  class Request < ApplicationRecord
    include Material

    belongs_to :library_type
    belongs_to :data_type

    validates :cost_code, presence: true
    validates :number_of_flowcells, numericality: { only_integer: true, greater_than: 0 }
    validates :external_study_id, uuid: true

    validates :library_type, pipeline: :ont
    validates :data_type, pipeline: :ont
  end
end
