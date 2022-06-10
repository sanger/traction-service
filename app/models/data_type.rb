# frozen_string_literal: true

# A data-type communicates information downstream regarding how the customer
# would like their data processed.
class DataType < ApplicationRecord
  enum pipeline: Pipelines::ENUMS, _suffix: true

  validates :pipeline, presence: true
  validates :name, presence: true, uniqueness: { scope: :pipeline }
end
