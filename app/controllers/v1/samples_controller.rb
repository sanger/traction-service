module V1
  class SamplesController < ApplicationController
    def create
      factory = SampleFactory.new(params_names)
      if factory.save
        head :created
      else
        render json: {:errors => factory.errors.messages}.to_json, status: :unprocessable_entity
      end
    end

    def params_names
      params.require(:data).require(:attributes)[:samples].map{|param| param.permit(:name).to_h}
    end
  end
end
