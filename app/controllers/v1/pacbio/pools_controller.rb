# frozen_string_literal: true

module V1
  module Pacbio
    # PoolsController
    class PoolsController < ApplicationController
      def create
        @pool_factory = ::Pacbio::PoolFactory.new(pool_params)
        if @pool_factory.save!
          head :created
        else
          render json: { data: { errors: @pool_factory.errors.messages } },
                 status: :unprocessable_entity
        end
      end
    end
  end
end

private

def pool_params
  params.require(:data)['attributes'].permit(
    { libraries:
        %i[template_prep_kit_box_barcode volume concentration fragment_size pacbio_request_id
           tag_id] }
  ).to_h
end
