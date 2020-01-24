# frozen_string_literal: true

# Represents a collection of tags, generally bought together as a product
# Also known as a barcode set
class TagSet < ApplicationRecord
  has_many :tags, dependent: :restrict_with_error
end
