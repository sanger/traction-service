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
      if except == :container_material
        [library: Ont::Library.includes_args(:requests), tags: Tag.includes_args]
      elsif except == :library
        [container_material: ContainerMaterial.includes_args(:material), tags: Tag.includes_args]
      elsif except == :tags
        [container_material: ContainerMaterial.includes_args(:material),
         library: Ont::Library.includes_args(:requests)]
      else
        [container_material: ContainerMaterial.includes_args(:material),
         library: Ont::Library.includes_args(:requests),
         tags: Tag.includes_args]
      end
    end
  end
end
