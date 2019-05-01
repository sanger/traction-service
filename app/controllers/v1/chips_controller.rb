# frozen_string_literal: true

module V1
  # ChipsController
  class ChipsController < ApplicationController
    def update
      attributes = params.require(:data)['attributes'].permit(:barcode)
      chip.update(attributes)
      head :ok
    rescue StandardError => e
      data = { data: { errors: e.message } }
      render json: data, status: :unprocessable_entity
    end

    private

    def chip
      @chip ||= Chip.find(params[:id])
    end
  end
end
