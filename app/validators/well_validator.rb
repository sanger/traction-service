# frozen_string_literal: true

# Failed validations return unprocessable_entity
class WellValidator < ActiveModel::Validator
  def validate(record)
    # First we want to check there is at least 1 library or pool
    validate_library_presence(record)

    # The next validations rely on there being more than 1 library or pool
    return unless record.all_libraries.many?

    validations = %i[validate_library_presence validate_tag_presence validate_tag_uniqueness]

    validations.each do |validation|
      next if record.errors.present?

      send(validation, record)
    end
  end

  def validate_library_presence(record)
    return unless record.all_libraries.empty?

    record.errors.add(:base, "There must be at least 1 pool or library for well #{record.position}")
    nil
  end

  def validate_tag_presence(record)
    all_tags = record.all_libraries.collect(&:tag)

    return unless all_tags.empty? || all_tags.any?(nil)

    record.errors.add(:tags, 'are missing from the libraries')
    nil
  end

  def validate_tag_uniqueness(record)
    all_tags = record.all_libraries.collect(&:tag)

    return if all_tags.length == all_tags.uniq.length

    record.errors.add(:tags, "are not unique within the libraries for well #{record.position}")
    nil
  end
end
