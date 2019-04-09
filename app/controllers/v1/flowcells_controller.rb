# frozen_string_literal: true

module V1
  # FlowcellsController
  class FlowcellsController < ApplicationController
    def update
      attributes = params.require(:data)['attributes'].permit(:library_id)
      library = Library.find(attributes['library_id'])
      flowcell.update(library: library)
      head :ok
    rescue StandardError => e
      render json: { errors: e.message }, status: :unprocessable_entity
    end

    private

    def flowcell
      @flowcell ||= Flowcell.find(params[:id])
    end
  end
end
