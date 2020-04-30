# frozen_string_literal: true

# Ont namespace
module Ont
  # RequestFactory
  # The factory will build a request and associated sample
  # from the input attributes
  class RequestFactory
    include ActiveModel::Model

    validate :check_request, :check_tag

    def initialize(attributes = {}, tag_service = nil)
      @well = attributes[:well]
      @tag_service = tag_service
      return unless attributes.key?(:request_attributes)

      build_request(attributes[:request_attributes])
    end

    attr_reader :request

    def save
      return false unless valid?

      request.save
      @tag_taggable&.save
      @well_request_join.save
      true
    end

    private

    def build_request(request_attributes)
      constants_accessor = Pipelines::ConstantsAccessor.new(Pipelines.ont.covid)
      sample = build_or_fetch_sample(request_attributes, constants_accessor)
      ont_request = build_ont_request(request_attributes, constants_accessor)
      @request = ::Request.new(requestable: ont_request, sample: sample)
      @well_request_join = ::ContainerMaterial.new(container: @well, material: request.requestable)
    end

    def build_ont_request(request_attributes, constants_accessor)
      ont_request = Ont::Request.new(external_study_id: constants_accessor.external_study_id)
      unless @tag_service.nil?
        if request_attributes.key?(:tag_group_id)
          tag = @tag_service.find_and_register_tag(request_attributes[:tag_group_id])
          @tag_taggable = ::TagTaggable.new(taggable: ont_request, tag: tag)
        end
      end
      ont_request
    end

    def build_or_fetch_sample(request_attributes, constants_accessor)
      sample_attributes = request_attributes
                          .extract!(:name, :external_id)
                          .merge!(species: constants_accessor.species)
      Sample.find_or_initialize_by(sample_attributes)
    end

    def check_request
      if request.nil?
        errors.add('request', 'cannot be nil')
        return
      end

      return if request.valid?

      request.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def check_tag
      return if @tag_service.nil?

      if @tag_taggable.nil?
        errors.add('request', 'must have a tag')
        return
      end

      return if @tag_taggable.valid?

      @tag_taggable.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
