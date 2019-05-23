# frozen_string_literal: true

module V1
  # SamplesController
  class SamplesController < ApplicationController
    #  TODO: add index
    def create
      @sample_factory = SampleFactory.new(params_names)
      if @sample_factory.save
        @sample_resources = @sample_factory.samples.map { |sample| SampleResource.new(sample, nil) }
        render json:
          JSONAPI::ResourceSerializer.new(SampleResource).serialize_to_hash(@sample_resources),
               status: :created
      else
        render json: { data: { errors: @sample_factory.errors.messages } },
               status: :unprocessable_entity
      end
    end

    def params_names
      params.require(:data).require(:attributes)[:samples].map do |param|
        param.permit(:external_id, :external_study_id, :name, :species).to_h
      end
    end
  end
end
