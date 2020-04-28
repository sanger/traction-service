# frozen_string_literal: true

# Taggable
module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tag_taggables, as: :taggables, dependent: :destroy # Will it only destroy the join table entry?

    def tags
      return tag_taggables.map { |tag_taggable| tag_taggable.tags }
    end
  end
end
