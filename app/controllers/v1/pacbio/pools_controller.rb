# frozen_string_literal: true

module V1
  module Pacbio
    # PoolsController
    class PoolsController < ApplicationController
      def create
        @pool = ::Pacbio::PoolFactory.new
      end
    end
  end
end
