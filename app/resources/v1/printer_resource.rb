# frozen_string_literal: true

module V1
  #
  # @note Access this resource via the `/v1/printer_types` endpoint.
  #
  # Provides a JSON:API representation of {Printer}
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  #
  ## Filters:
  # * name
  # * labware_type
  # * active
  #
  # @example
  #   curl -X GET http://localhost:3000/v1/printers/1
  #   curl -X GET http://localhost:3000/v1/printers/
  #   curl -X GET "http://localhost:3000/v1/printers?filter[name]=printer_name"
  #   curl -X GET "http://localhost:3000/v1/printers?filter[labware_type]=tube_rack_24"
  #   curl -X GET "http://localhost:3000/v1/printers?filter[active]=true"
  #
  class PrinterResource < JSONAPI::Resource
    model_name 'Printer', add_model_hint: false

    # @!attribute [rw] name
    #   @return [String] the name of the printer
    # @!attribute [rw] labware_type
    #   @return [String] the type of labware the printer handles
    # @!attribute [rw] active?
    #   @return [Boolean] the active status of the printer
    # @!attribute [rw] created_at
    #   @return [String] the timestamp when the printer was created
    # @!attribute [rw] updated_at
    #   @return [String] the timestamp when the printer was last updated
    # @!attribute [rw] deactivated_at
    #   @return [DateTime, nil] the timestamp when printer was deactivated, or nil if it is active
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
