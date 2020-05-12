# frozen_string_literal: true

# Taggable
module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tag_taggables, as: :taggable, dependent: :destroy
    has_many :tags, through: :tag_taggables
  end

  # returns tags sorted by tag_set id, then tag id
  def sorted_tags
    tags.sort { |a, b| a.tag_set.id == b.tag_set.id ? a.id <=> b.id : a.tag_set.id <=> b.tag_set.id }
  end
end
