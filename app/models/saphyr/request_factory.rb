# frozen_string_literal: true

module Saphyr
  # RequestFactory
  class RequestFactory
    include ActiveModel::Model

    validate :check_requests, :check_requestables

    # @param attributes [Array of ActionController::Parameters] list of request parameters
    # @return [Array of ActiveRecord Requests]
    def initialize(attributes = [])
      raise if Flipper.enabled?(:dpl_277_disable_saphyr_specific_reception)

      build_requests(attributes)
    end

    # @return [Array of ActiveRecord Requests]
    def requests
      @request_wrappers.collect(&:request)
    end

    # @return [Array of ActiveRecord Requestables]
    def requestables
      @request_wrappers.collect(&:requestable)
    end

    # checks if the factory is valid, if so will save all of the requests
    # @return [Boolean] if the requests have been successfully saved or not
    def save
      ApplicationRecord.transaction do
        return false unless valid?

        @request_wrappers.all?(&:save)
      end
    rescue StandardError => e
      errors.add(:base, e.message)
      false
    end

    # Takes each set of request attributes:
    # * extracts the sample attributes
    # * builds a new request with the request attributes
    # * builds a new tube
    # * builds or finds the sample if it already exists
    # @param attributes [Array of ActionController::Parameters] list of request parameters
    # @return [Array of ActiveRecord Requests]
    def build_requests(attributes)
      @request_wrappers = attributes.map do |request_attributes|
        RequestWrapper.new(**request_attributes)
      end
    end

    # Handles the creation of the request, containers and samples for each request
    # passed to the factory
    # Note: This approach will have some issues with scalability if large numbers of tubes
    # are imported at once, as we hit the database per tube/sample.
    # However, there is a need to update this to a more resource based solution,
    # so we'll defer this problem for now
    class RequestWrapper
      include ActiveModel::Model

      attr_reader :sample, :requestable

      def tube
        @tube ||= Tube.new
      end

      def request
        @request ||= ::Request.new(requestable: requestable, sample: sample)
      end

      def container_material
        @container_material ||= ContainerMaterial.new(container: tube, material: requestable)
      end

      def save
        raise if Flipper.enabled?(:dpl_277_disable_saphyr_specific_reception)

        tube.save! && request.save! && container_material.save!
      end

      def sample=(sample_attributes)
        @sample = Sample.find_or_initialize_by(sample_attributes)
      end

      def request=(request_attributes)
        @requestable = Saphyr::Request.new(request_attributes)
      end

      def tube=(tube_attributes)
        @tube = Tube.find_or_initialize_by(tube_attributes)
      end
    end

    # Validates the requests:
    # * if there are no requests returns an error
    # * checks each request and if it is not valid adds the errors to the factory
    def check_requests
      if requests.empty?
        errors.add('requests', 'there were no requests')
        return
      end

      requests.each do |request|
        next if request.valid?

        request.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      end
    end

    # Validates the requestables:
    # * checks each requestable and if it is not valid adds the errors to the factory
    def check_requestables
      requestables.each do |requestable|
        next if requestable.valid?

        requestable.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      end
    end
  end
end
