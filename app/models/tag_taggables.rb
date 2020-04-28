# frozen_string_literal: true

# TagTaggable
# A tag_taggable provides a link between tags and taggables
# This means that a taggable can belong to more than one tag
# And a tag can have more than one taggable
class TagTaggable < ApplicationRecord
  belongs_to :taggable, polymorphic: true
  belongs_to :tag
end
