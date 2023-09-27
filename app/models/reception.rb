# frozen_string_literal: true

# A reception handles the import of samples and requests from external sources
# While it is not necessary to persist it, is does provide a useful point for
# auditing and event tracking purposes.
class Reception < ApplicationRecord
  extend NestedValidation
  has_many :requests, dependent: :restrict_with_error

  # Source is used to track where a reception event came from.
  # Anything going via traction-ui (ie. everything initially) should be prefixed
  # traction-ui. For example traction-ui.sequencescape or traction-ui.samples-extraction
  # Validation here is a bit strict to maintain consistency. Especially if we end up with
  # external collaborators
  validates :source, presence: true, format: /\A[a-z0-9\-.]+\z/

  delegate :plates_attributes=, :tubes_attributes=, to: :resource_factory_v2
  delegate :request_attributes=, to: :resource_factory_v1
  delegate :construct_resources!, to: :resource_factory
  # We flatten the keys here as they map back directly to the correpsonding
  # attributes in Reception. We're merely using the ResourceFactory to
  # encapsulate the behaviour
  validates_nested :resource_factory, flatten_keys: true

  private

  attr_reader :resource_factory

  def resource_factory_v1
    # Returns V1 factory unless factory has been set to v2
    if @resource_factory.nil? || @resource_factory.is_a?(ResourceFactoryV1)
      return @resource_factory ||= ResourceFactoryV1.new(reception: self)
    end

    raise 'Cannot mix v1 and v2 reception resources'
  end

  def resource_factory_v2
    # Returns V2 factory unless factory has been set to v1
    if @resource_factory.nil? || @resource_factory.is_a?(ResourceFactoryV2)
      return @resource_factory ||= ResourceFactoryV2.new(reception: self)
    end

    raise 'Cannot mix v1 and v2 reception resources'
  end
end
