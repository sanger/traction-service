module V1
  class SamplesController < ApplicationController
    def create
      @sample_factory = SampleFactory.new(params_names)
      if @sample_factory.save
        @sample_resources = @sample_factory.samples.map { |sample| SampleResource.new(sample, nil) }
        render json: JSONAPI::ResourceSerializer.new(SampleResource).serialize_to_hash(@sample_resources), status: :created
      else
        render json: { errors: @sample_factory.errors.messages}, status: :unprocessable_entity
      end
    end

    # def index
    #   render json:  JSONAPI::ResourceSerializer.new(SampleResource).serialize_to_hash(Sample.all)
    # end

    def params_names
      params.require(:data).require(:attributes)[:samples].map{|param| param.permit(:sequencescape_request_id, :name, :state, :species).to_h}
    end
  end

end
