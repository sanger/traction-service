# frozen_string_literal: true

module V1
  # A Reception handles the import of resources into traction
  class ReceptionResource < JSONAPI::Resource
    attributes :requests, :source

    def requests; end

    def requests=(args); end
  end
end
