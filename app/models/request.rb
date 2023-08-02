# frozen_string_literal: true

# Request
class Request < ApplicationRecord
  belongs_to :sample
  belongs_to :requestable, polymorphic: true, inverse_of: :request
  belongs_to :reception, optional: true

  validates_associated :sample, :requestable

  # StockResourceData creates an artificial structure to provide sample and
  # requestable together as part of a list. This is because the StockResource
  # message going to the warehouse needs to provide samples as a list, but
  # in the model there is only one single sample. This class helps converting the
  # sample relation into a list of samples with only one single element.
  # See StockResource 'samples' at pipelines.yml
  class StockResourceData
    attr_reader :sample, :requestable

    def initialize(sample, requestable)
      @sample = sample
      @requestable = requestable
    end
  end

  def samples_for_stock_resource
    [Request::StockResourceData.new(sample, requestable)]
  end
end
