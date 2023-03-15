# frozen_string_literal: true

# Validates that the model to create is not going to refer to a container
# which already have requests in it
class ResourceFactoryValidator < ActiveModel::Validator
  def validate(record)
    containers = record.request_attributes.map(&:container).compact.uniq
    containers.each do |container|
      if container.already_exists? && container.existing_records_have_requests?
        record.errors.add :container, "The container #{container.barcode} already exists"
      end
    end
  end
end
