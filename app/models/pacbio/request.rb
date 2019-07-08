# frozen_string_literal: true

module Pacbio
  # Pacbio::Request
  class Request < ApplicationRecord
    include Pipelines::Requestor::Model
  end
end
