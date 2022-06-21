# frozen_string_literal: true

# A reception handles the import of samples and requests from external sources
# While it is not necessary to persist it, is does provide a useful point for
# auditing and event tracking purposes.
class Reception < ApplicationRecord
  extend NestedValidation
  # Source is used to track where a reception event came from.
  # Anything going via traction-ui (ie. everything initially) should be prefixed
  # traction-ui. For example traction-ui.sequencescape or traction-ui.samples-extraction
  # Validation here is a bit strict to maintain consistency. Especially if we end up with
  # external collaberators
  validates :source, presence: true, format: /\A[a-z0-9\-.]+\z/

  delegate :request_attributes=, :construct_resources!, to: :resource_factory

  # We flatten the keys here as they map back directly to the correpsonding
  # attributes in Reception. We're merely using the ResourceFactory to
  # encapsulate the behaviour
  validates_nested :resource_factory, flatten_keys: true

  private

  def resource_factory
    @resource_factory ||= ResourceFactory.new(reception: self)
  end
end
