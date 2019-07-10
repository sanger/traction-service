# frozen_string_literal: true

module Pipelines
  module Requestor
    # Factory - behaviour for pipeline requests factory
    module Factory
      extend ActiveSupport::Concern

      include ActiveModel::Model

      included do
        validate :check_requests
      end

      # Model ClassMethods
      module ClassMethods
        def pipeline
          @pipeline ||= name.to_s.deconstantize
        end

        def request_model
          @request_model ||= "#{pipeline}::Request".constantize
        end
      end

      def initialize(attributes = [])
        build_requests(attributes)
      end

      def requests
        @requests ||= []
      end

      def requestables
        requests.collect(&:requestable)
      end

      def save
        return false unless valid?

        requests.collect(&:save)
        true
      end

      def build_requests(attributes)
        attributes.each do |request|
          sample_attributes = request.extract!(:name, :external_id, :species)
          requests << ::Request.new(requestable:
            self.class.request_model.new(request.merge!(tube: Tube.new)),
                                    sample: Sample.find_or_initialize_by(sample_attributes))
        end
      end

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
