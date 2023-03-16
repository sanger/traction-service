# frozen_string_literal: true

# Failed validations return unprocessable_entity
class WellValidator < ActiveModel::Validator
  include ActiveModel::Validations

  def validate(record)
    # return unless there are multiple libraries
    return unless record.pools.map(&:libraries).flatten.many?

    validations = %i[validate_tag_presence validate_tag_uniqueness]

    validations.each do |validation|
      next if record.errors.present?

      send(validation, record)
    end
  end

  def validate_tag_presence(record)
    all_tags = record.pools.map(&:libraries).flatten.collect(&:tag)

    return unless all_tags.empty? || all_tags.any?(nil)

    record.errors.add(:tags, 'are missing from the libraries')
    nil
  end

  def validate_tag_uniqueness(record)
    all_tags = record.pools.map(&:libraries).flatten.collect(&:tag)

    return if all_tags.length == all_tags.uniq.length

    record.errors.add(:tags, "are not unique within the libraries for well #{record.position}")
    nil
  end
end
