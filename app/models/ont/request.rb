# frozen_string_literal: true

module Ont
  # Ont::Request
  class Request < ApplicationRecord
    include Material
    include Taggable

    belongs_to :library, foreign_key: :ont_library_id, inverse_of: :requests,
                         dependent: :destroy, optional: true
    validates :name, :external_id, presence: true

    def self.includes_args(except = nil)
      args = []
      args << { tags: Tag.includes_args } unless except == :tags
      args << { library: Ont::Library.includes_args(:requests) } unless except == :library

      unless except == :container_material
        args << { container_material: ContainerMaterial.includes_args(:material) }
      end

      args
    end
  end
end
