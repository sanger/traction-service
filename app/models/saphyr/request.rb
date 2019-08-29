# frozen_string_literal: true

require 'saphyr/saphyr'

module Saphyr
  # Saphyr::Request
  # A saphyr request is a material
  # A saphyr request can have many libraries
  # A saphyr request can have one sample
  class Request < ApplicationRecord
    include Pipelines::Requestor::Model
  end
end
