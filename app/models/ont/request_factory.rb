# frozen_string_literal: true

# Ont namespace
module Ont
  # RequestFactory
  # The factory will build a request and associated sample
  # from the input attributes
  class RequestFactory
    include ActiveModel::Model

    validate :check_ont_request, :check_tag_taggable, :check_well_request_join

    def initialize(attributes = {})
      @well = attributes[:well]
      return unless attributes.key?(:request_attributes)

      build_request(attributes[:request_attributes])
    end

    attr_reader :ont_request

    def save(**options)
      return false unless options[:validate] == false || valid?

      # No need to validate any lower level objects since validation above has already checked them
      ActiveRecord::Base.transaction do
        ont_request.save(validate: false)
        tag_taggable.save(validate: false)
        well_request_join.save(validate: false)
      end
      true
    end

    private

    attr_reader :tag_taggable, :well, :well_request_join

    def build_request(request_attributes)
      tag_set_id = TagSet.find_by(name: Pipelines::ConstantsAccessor.ont_covid_pcr_tag_set_name)
      tag = ::Tag.find_by(tag_set_id: tag_set_id, oligo: request_attributes[:tag_oligo])
      @ont_request = Ont::Request.new(external_id: request_attributes[:external_id],
                                      name: request_attributes[:name])
      @tag_taggable = ::TagTaggable.new(taggable: ont_request, tag: tag)
      add_to_well(ont_request)
    end

    def add_to_well(material)
      @well_request_join = ::ContainerMaterial.new(container: well, material: material)
    end

    def check_ont_request
      if ont_request.nil?
        errors.add('request', 'cannot be nil')
        return
      end

      return if ont_request.valid?

      ont_request.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def check_tag_taggable
      if tag_taggable.nil?
        errors.add('tag', 'cannot be nil')
        return
      end

      return if tag_taggable.valid?

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
