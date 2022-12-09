# frozen_string_literal: true

module V1
  module Ont
    # Ont Pools Controller
    class PoolsController < ApplicationController
      before_action { not_found unless Flipper.enabled?(:dpl_279_ont_libraries_and_pools) }
    end
  end
end
