# frozen_string_literal: true

# A reception handles the import of samples and requests from external sources
# While it is not necessary to persist it, is does provide a useful point for
# auditing and event tracking purposes.
class Reception < ApplicationRecord
  # Source is used to track where a reception event came from.
  # Anything going via traction-ui (ie. everything initially) should be prefixed
  # traction-ui. For example traction-ui.sequencescape or traction-ui.samples-extraction
  # Validation here is a bit strict to maintain consistency. Especially if we end up with
  # external collaberators
  validates :source, presence: true, format: /\A[a-z0-9\-.]+\z/
end
