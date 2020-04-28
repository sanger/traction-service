# frozen_string_literal: true

# Taggable
module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tag_taggables, as: :taggable, dependent: :destroy

    def tags
      return tag_taggables.map { |tag_taggable| tag_taggable.tag }
    end
  end
end
