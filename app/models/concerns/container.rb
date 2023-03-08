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
      return self.class.by_barcode(barcode) unless respond_to?(:position) && position

      self.class.by_barcode_and_position(barcode, position)
    end

    def already_exists?
      existing_records.count > 0
    end

    def existing_records_have_requests?
      existing_records.joins(:container_materials).count > 0
    end
  end
end
