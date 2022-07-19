# frozen_string_literal: true

# A data-type communicates information downstream regarding how the customer
# would like their data processed.
# This information is passed to NPG in the warehouse, and adjusts the data
# made available to the customer. For example, 'basecalls and raw data'
# indicates that the customer would like the raw data included along with the
# processed basecalls
class DataType < ApplicationRecord
  include Pipelineable

  validates :pipeline, presence: true
  validates :name, presence: true, uniqueness: { scope: :pipeline }
end
