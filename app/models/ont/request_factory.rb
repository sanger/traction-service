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
      return unless attributes.key?(:sample_attributes) && attributes.key?(:tag_ids_by_oligo)

      @tag_ids_by_oligo = attributes[:tag_ids_by_oligo]
      build_request(attributes[:sample_attributes])
    end

    def bulk_insert_serialise(bulk_insert_serialiser, **options)
      return false unless options[:validate] == false || valid?

      bulk_insert_serialiser.ont_request_data(ont_request, tag_id)
    end

    private

    attr_reader :tag_ids_by_oligo, :ont_request, :tag_id

    def build_request(request_attributes)
      @tag_id = tag_ids_by_oligo[request_attributes[:tag_oligo]]
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
