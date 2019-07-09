# frozen_string_literal: true

module V1
  module Pacbio
    # RequestsController
    class RequestsController < ApplicationController
      include Pipelines::Requestor::Controller
    end
  end
end
