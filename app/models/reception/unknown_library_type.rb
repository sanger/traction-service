# frozen_string_literal: true

class Reception
  # Returned when we don't recognize the library type
  class UnknownLibraryType
    include ActiveModel::Model

    attr_accessor :library_type, :permitted

    validates :library_type, inclusion: { in: ->(object) { object.permitted } }

    def request_factory(_attributes)
      self
    end
  end
end
