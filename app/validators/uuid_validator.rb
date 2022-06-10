# frozen_string_literal: true

# UuidValidator
# Validates that the supplied value is a valid uuid
# by regular expression. This is a little more permissive
# than strictly governed by the UUID format, but we're more
# likely to see technically 'valid' uuids, which just don't
# map to a resource, so lets keep things simple.
class UuidValidator < ActiveModel::EachValidator
  UUID = /\A[0-f]{8}-([0-f]{4}-){3}[0-f]{12}\z/.freeze

  def validate_each(record, attribute, value)
    return if UUID.match?(value)

    record.errors.add(attribute, :uuid)
  end
end
