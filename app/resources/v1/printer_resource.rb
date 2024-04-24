# frozen_string_literal: true

module V1
  # PrinterResource
  class PrinterResource < JSONAPI::Resource
    model_name 'Printer', add_model_hint: false

    attributes :name, :labware_type, :active?, :created_at, :updated_at, :deactivated_at

    paginator :paged

    filter :name, apply: lambda { |records, value, _options|
      records.where('name LIKE ?', "%#{value[0]}%")
    }

    filter :labware_type, apply: lambda { |records, value, _options|
      labware_types = Printer.labware_types.keys
      unless labware_types.include?(value[0])
        raise(JSONAPI::Exceptions::InvalidFilterValue.new(:labware_type, value[0]))
      end

      records.where(labware_type: value[0])
    }

    filter :active, apply: lambda { |records, value, _options|
      value[0] == 'true' ? records.active : records.inactive
    }
  end
end
