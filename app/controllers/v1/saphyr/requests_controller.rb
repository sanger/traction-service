# frozen_string_literal: true

module V1
  module Saphyr
    # RequestsController
    class RequestsController < ApplicationController
      include Pipelines::Requestor::Controller
    end
  end
end
