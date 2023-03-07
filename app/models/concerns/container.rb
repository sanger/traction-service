# frozen_string_literal: true

# Container
module Container
  extend ActiveSupport::Concern

  included do
    has_many :container_materials, as: :container, dependent: :destroy

    def materials
      container_materials.map(&:material)
    end

    def existing_records
      return self.class.by_barcode(self.barcode) unless self.position
      self.class.by_barcode_and_position(self.barcode, self.position)
    end

    def already_exists?
      existing_records.count > 0
    end

    def has_requests?
      existing_records.with_requests.count > 0
    end
  end
end
