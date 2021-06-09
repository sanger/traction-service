# frozen_string_literal: true

module Pipelines
  module Requestor
    # Model - behaviour for pipeline requests model
    # includes various bits of behaviour in the model:
    # * the Material concern
    # * request association
    # * sample association
    # * delegation of sample attributes readers
    # * validation to check that each of the request attributes is present
    module Model
      extend ActiveSupport::Concern

      include TubeMaterial

      included do
        has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
        has_one :sample, through: :request

        delegate :name, to: :sample, prefix: :sample
        delegate :species, to: :sample, prefix: :sample

        validates(*to_s.deconstantize.constantize.required_request_attributes, presence: true)
      end

      def source_identifier
        container&.identifier
      end
    end
  end
end
