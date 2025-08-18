# frozen_string_literal: true

# Represents a collection of tags, generally bought together as a product
# Also known as a barcode set
class TagSet < ApplicationRecord
  include Pipelineable

  has_many :tags, dependent: :restrict_with_error

  enum :sample_sheet_behaviour, { default: 0, hidden: 1 }, suffix: true

  validates :name, presence: true
  validates :pipeline, presence: true
end
