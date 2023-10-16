# frozen_string_literal: true

# DEPRECATE-Reception-V1:
# Delegate constructue_resources! to resource_factory directly
# Remove resource_factory_v1 and set resource_factory_v2 as resource_factory

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
  # We flatten the keys here as they map back directly to the correpsonding
  # attributes in Reception. We're merely using the ResourceFactory to
  # encapsulate the behaviour
  validates_nested :resource_factory, flatten_keys: true

  def construct_resources!
    # Instead of delegating to resource factory
    # We need to check the factory exists first since it can be nil
    @resource_factory&.construct_resources!
  end

  private

  attr_reader :resource_factory

  # We use a memoized instance variable here to ensure we only
  # ever have one resource factory per reception and that we use
  # the correct behaviour given the parameters passed in

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def resource_factory_v1
    # Returns V1 factory unless V2 factory has been set
    if @resource_factory.is_a?(ResourceFactoryV2)
      raise JSONAPI::Exceptions::BadRequest, 'Cannot mix v1 and v2 reception resources'
    end

    @resource_factory ||= ResourceFactoryV1.new(reception: self)
  end

  def resource_factory_v2
    # Returns V2 factory unless V1 factory has been set
    if @resource_factory.is_a?(ResourceFactoryV1)
      raise JSONAPI::Exceptions::BadRequest, 'Cannot mix v1 and v2 reception resources'
    end

    @resource_factory ||= ResourceFactoryV2.new(reception: self)
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName
end
