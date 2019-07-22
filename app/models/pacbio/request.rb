# frozen_string_literal: true

require 'pacbio/pacbio'

module Pacbio
  # Pacbio::Request
  class Request < ApplicationRecord
    include Pipelines::Requestor::Model
  end
end
