# frozen_string_literal: true

module V1
  module Saphyr
    # FlowcellsController
    class FlowcellsController < ApplicationController
      before_action :library, only: [:update]

      def create
        @flowcell = ::Saphyr::Flowcell.new(params_names)
        if @flowcell.save
          Messages.publish(@flowcell, Pipelines.saphyr.message)
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
        flowcell.update(library: library)
        Messages.publish(flowcell, Pipelines.saphyr.message)
        render json:
          JSONAPI::ResourceSerializer.new(FlowcellResource)
                                     .serialize_to_hash(FlowcellResource.new(flowcell, nil)),
               status: :ok
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
        params.require(:data)['attributes'].permit(:position, :saphyr_library_id, :saphyr_chip_id)
      end

      def library
        @library ||= ::Saphyr::Library.find(params_names['saphyr_library_id'])
      end

      def flowcell
        @flowcell ||= ::Saphyr::Flowcell.find(params[:id])
      end
    end
  end
end
