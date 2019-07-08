module Requestable
  extend ActiveSupport::Concern

  include Material

  included do
    has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
    has_one :sample, through: :request
    delegate :name, to: :sample, prefix: :sample
  end
end