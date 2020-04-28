# frozen_string_literal: true

# Taggable
module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tag_taggables, as: :taggable, dependent: :destroy
    has_many :tags, through: :tag_taggables
  end
end
