# frozen_string_literal: true

module V1
  # ChipsController
  class ChipsController < ApplicationController
    def update
      attributes = params.require(:data)['attributes'].permit(:barcode)
      chip.update(attributes)
      head :ok
    rescue StandardError => exception
      render json: { errors: exception.message }, status: :unprocessable_entity
    end

    private

    def chip
      @chip ||= Chip.find(params[:id])
    end
  end
end
