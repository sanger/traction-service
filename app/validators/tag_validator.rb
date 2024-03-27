# frozen_string_literal: true

# TagValidator
# if the pool only has one library no need to check
# if there is more than one library each one will require a tag
# if there is more than one library each tag will need to be unique
class TagValidator < ActiveModel::Validator
  def validate(record)
    if Flipper.enabled?(:multiplexing_phase_2_aliquot)
      validate_used_aliquots(record)
    else
      validate_libraries(record)
    end
  end

  def validate_used_aliquots(record)
    return if record.used_aliquots.length < 2

    tags = record.used_aliquots.collect(&:tag)
    record.errors.add(:tags, 'must be present on all libraries') if tags.any?(&:nil?)
    record.errors.add(:tags, 'contain duplicates') unless tags.length == tags.uniq.length
  end

  def validate_libraries(record)
    return if record.libraries.length < 2

    tags = record.libraries.collect(&:tag)
    record.errors.add(:tags, 'must be present on all libraries') if tags.any?(&:nil?)
    record.errors.add(:tags, 'contain duplicates') unless tags.length == tags.uniq.length
  end
end
