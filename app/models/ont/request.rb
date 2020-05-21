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
        [library: Ont::Library.includes_args(:requests), tags: :tag_set]
      elsif except == :library
        [container_material: :container, tags: :tag_set]
      elsif except == :tags
        [container_material: :container, library: Ont::Library.includes_args(:requests)]
      else
        [container_material: :container,
         library: Ont::Library.includes_args(:requests),
         tags: :tag_set]
      end
    end
  end
end
