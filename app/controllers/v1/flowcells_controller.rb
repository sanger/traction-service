# frozen_string_literal: true

module V1
  # FlowcellsController
  class FlowcellsController < ApplicationController
    def create
      @flowcell = Flowcell.new(params_names)
      if @flowcell.save
        render json:
          JSONAPI::ResourceSerializer.new(FlowcellResource)
                                     .serialize_to_hash(FlowcellResource.new(flowcell, nil)),
               status: :created
      else
        render json: { data: { errors: @flowcell.errors.messages } },
               status: :unprocessable_entity
      end
    end

    def update
      library = Library.find(params_names['library_id'])
      flowcell.update(library: library)
      head :ok
    rescue StandardError => e
      render json: { data: { errors: e.message } }, status: :unprocessable_entity
    end

    def destroy
      if flowcell.destroy
        head :no_content
      else
        render json: { data: { errors: flowcell.errors.messages } }, status: :unprocessable_entity
      end
    end

    private

    def params_names
      params.require(:data)['attributes'].permit(:position, :library_id, :chip_id)
    end

    def flowcell
      @flowcell ||= Flowcell.find(params[:id])
    end
  end
end
