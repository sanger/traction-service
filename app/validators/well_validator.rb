# frozen_string_literal: true

# Failed validations return unprocessable_entity
class WellValidator < ActiveModel::Validator
  def validate(record)
    return unless record.base_used_aliquots.many?

    validations = %i[validate_tag_presence validate_tag_uniqueness]

    validations.each do |validation|
      next if record.errors.present?

      send(validation, record)
    end
  end

  def validate_tag_presence(record)
    all_tags = record.base_used_aliquots.collect(&:tag)

    return unless all_tags.empty? || all_tags.any?(nil)

    record.errors.add(:tags, 'are missing from the libraries')
    nil
  end

  def validate_tag_uniqueness(record)
    all_tags = record.base_used_aliquots.collect(&:tag)

    return if all_tags.length == all_tags.uniq.length

    record.errors.add(:tags, "are not unique within the libraries for well #{record.position}")
    nil
  end
end
