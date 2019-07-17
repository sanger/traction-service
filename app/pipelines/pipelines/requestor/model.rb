# frozen_string_literal: true

require 'saphyr/saphyr'
require 'pacbio/pacbio'

module Pipelines
  module Requestor
    # Model - behaviour for pipeline requests model
    module Model
      extend ActiveSupport::Concern

      include Material

      included do
        has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
        has_one :sample, through: :request

        delegate :name, to: :sample, prefix: :sample

        validates(*to_s.deconstantize.constantize.request_attributes, presence: true)
      end
    end
  end
end
