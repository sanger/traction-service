# frozen_string_literal: true

# RequestFactory
module Pacbio
  class RequestFactory
    include ActiveModel::Model

    def initialize(attributes = [])
    end

    def requests
      @requests ||= []
    end

  end
end
