# frozen_string_literal: true

module V1
  # TagsController
  class TagsController < ApplicationController
    def create
      @tag = Tag.new(params_names)
      if @tag.save
        head :created
      else
        render json: { data: { errors: @tag.errors.messages } },
               status: :unprocessable_content
      end
    end

    def update
      tag.update(params_names)
      render_json(:ok)
    rescue StandardError => e
      render json: { data: { errors: e.message } }, status: :unprocessable_content
    end

    def destroy
      tag.destroy
      head :no_content
    rescue StandardError => e
      render json: { data: { errors: e.message } }, status: :unprocessable_content
    end

    private

    def params_names
      params.require(:data)['attributes'].permit(:oligo, :oligo_reverse, :group_id, :tag_set_id)
    end

    def tag
      @tag ||= Tag.find(params[:id])
    end

    def render_json(status)
      render json: serialize_resource(TagResource.new(@tag, nil)), status:
    end
  end
end
