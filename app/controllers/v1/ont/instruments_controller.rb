# frozen_string_literal: true

module V1
  module Ont
    # InstrumentsController
    class InstrumentsController < ApplicationController
      before_action { not_found unless Flipper.enabled?(:dpl_281_ont_create_sequencing_runs) }
    end
  end
end
