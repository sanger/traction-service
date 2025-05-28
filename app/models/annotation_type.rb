# frozen_string_literal: true

# AnnotationType model
# This model represents the types of annotations that can be applied to resources.
class AnnotationType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
