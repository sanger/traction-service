# frozen_string_literal: true

module Saphyr
  # Request
  class Request < ApplicationRecord
    include Pipelines::Requestor::Model
  end
end
