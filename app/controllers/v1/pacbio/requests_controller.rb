# frozen_string_literal: true

module V1
  module Pacbio
    # RequestsController
    class RequestsController < ApplicationController
      include Pipelines::Requestor::Controller
      # TODO: add hook to send a message after update if there is a run attached
      # TODO: remove link to requestor controller
    end
  end
end
