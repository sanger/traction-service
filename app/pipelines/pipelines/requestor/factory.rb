# frozen_string_literal: true

module Pipelines
  module Requestor
    # Factory - behaviour for pipeline requests factory
    # It will take an array of request parameters and build an
    # array of request and associated samples (if they dont exist)
    # Also manages validation and saving
    module Factory
      extend ActiveSupport::Concern

      include ActiveModel::Model

      included do
        validate :check_requests
      end

      # Model ClassMethods
      module ClassMethods
        # @return [String] the name of the pipeline
        #  e.g. +pipeline('Pacbio::Request') = 'Pacbio'+
        def pipeline
          @pipeline ||= name.to_s.deconstantize
        end

        # @return [Constant] the ActiveRecord model for requests for the pipeline
        #  e.g. +request_model('Pacbio') = Pacbio::Request+
        def request_model
          @request_model ||= "#{pipeline}::Request".constantize
        end
      end

      # @param attributes [Array of ActionController::Parameters] list of request parameters
      # @return [Array of ActiveRecord Requests] for the chosen pipeline
      def initialize(attributes = [])
        build_requests(attributes)
      end

      # @return [Array of ActiveRecord Requests] for the chosen pipeline
      def requests
        @requests ||= []
      end

      # @return [Array of ActiveRecord Requestables] for the chosen pipeline
      def requestables
        requests.collect(&:requestable)
      end

      # checks if the factory is valid, if so will save all of the requests
      # @return [Boolean] if the requests have been successfully saved or not
      def save
        return false unless valid?

        requests.collect(&:save)
        true
      end

      # Takes each set of request attributes:
      # * extracts the sample attributes
      # * builds a new request with the request attributes
      # * builds a new tube
      # * builds or finds the sample if it already exists
      # @param attributes [Array of ActionController::Parameters] list of request parameters
      # @return [Array of ActiveRecord Requests] for the chosen pipeline
      def build_requests(attributes)
        attributes.each do |request|
          sample_attributes = request.extract!(:name, :external_id, :species)
          requests << ::Request.new(requestable:
            self.class.request_model.new(request.merge!(tube: Tube.new)),
                                    sample: Sample.find_or_initialize_by(sample_attributes))
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

          request.errors.each do |k, v|
            errors.add(k, v)
          end
        end
      end
    end
  end
end
