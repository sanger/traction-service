# frozen_string_literal: true

# Ont namespace
module Ont
  # RequestFactory
  # The factory will build a request and associated sample
  # from the input attributes
  class RequestFactory
    include ActiveModel::Model

    validate :check_request, :check_tag, :check_well_request_join
    # Note that @ont_request and @sample are validated by association with @request

    def initialize(attributes = {})
      @well = attributes[:well]
      @tag_service = attributes[:tag_service]
      return unless attributes.key?(:request_attributes)

      build_request(attributes[:request_attributes])
    end

    attr_reader :request

    def save(**options)
      return false unless options[:validate] == false || valid?

      # No need to validate any lower level objects since validation above has already checked them
      request.save(validate: false)
      tag_taggable&.save(validate: false)
      well_request_join.save(validate: false)
      true
    end

    private

    attr_reader :tag_taggable, :tag_service, :well, :well_request_join

    def build_request(request_attributes)
      constants_accessor = Pipelines::ConstantsAccessor.new(Pipelines.ont.covid)
      sample = build_or_fetch_sample(request_attributes, constants_accessor)
      ont_request = build_ont_request(request_attributes, constants_accessor)
      @request = ::Request.new(requestable: ont_request, sample: sample)
      @well_request_join = ::ContainerMaterial.new(container: well, material: request.requestable)
    end

    def build_ont_request(request_attributes, constants_accessor)
      ont_request = Ont::Request.new(external_study_id: constants_accessor.external_study_id)
      if request_attributes.key?(:tag_group_id)
        tag = @tag_service.find_and_register_tag(request_attributes[:tag_group_id])
        @tag_taggable = ::TagTaggable.new(taggable: ont_request, tag: tag)
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
      return if tag_taggable.nil? || tag_taggable.valid?

      tag_taggable.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def check_well_request_join
      return if well_request_join.nil? || well_request_join.valid?

      well_request_join.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
