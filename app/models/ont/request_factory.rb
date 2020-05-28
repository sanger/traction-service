# frozen_string_literal: true

# Ont namespace
module Ont
  # RequestFactory
  # The factory will build a request and associated sample
  # from the input attributes
  class RequestFactory
    include ActiveModel::Model

    validate :check_ont_request, :check_tag_exists

    def initialize(attributes = {})
      build_request(attributes)
    end

    def bulk_insert_serialise(plate_bulk_inserter, **options)
      return false unless options[:validate] == false || valid?

      plate_bulk_inserter.ont_request_data(ont_request, tag_id)
    end

    private

    attr_reader :ont_request, :tag_id

    def build_request(request_attributes)
      tag_set_id = TagSet.find_by(name: Pipelines::ConstantsAccessor.ont_covid_pcr_tag_set_name)
      @tag_id = Tag.find_by(tag_set_id: tag_set_id, oligo: request_attributes[:tag_oligo])&.id
      @ont_request = Ont::Request.new(external_id: request_attributes[:external_id],
                                      name: request_attributes[:name])
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

    def check_tag_exists
      errors.add('tag', 'does not exist') if tag_id.nil?
    end
  end
end
