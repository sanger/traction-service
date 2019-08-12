# frozen_string_literal: true

require 'saphyr/saphyr'

module Saphyr
  # Saphyr::Request
  class Request < ApplicationRecord
    include Pipelines::Requestor::Model
  end
end
