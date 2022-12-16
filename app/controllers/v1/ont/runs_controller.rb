# frozen_string_literal: true

module V1
  module Ont
    # JsonApi::Resource controllers are primarily handled by the corresponding
    # resources
    # See {Run} and {RunResource} for more information
    class RunsController < ApplicationController
      before_action { not_found unless Flipper.enabled?(:dpl_281_ont_create_sequencing_runs) }
    end
  end
end