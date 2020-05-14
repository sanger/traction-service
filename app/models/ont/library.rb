# frozen_string_literal: true

module Ont
  # Ont::Library
  class Library < ApplicationRecord
    include Material

    has_many :requests, foreign_key: :ont_library_id,
                        inverse_of: :library, dependent: :nullify

    validates :name, :pool, :pool_size, presence: true
    validates :name, uniqueness: { case_sensitive: false,
                                   message: 'must be unique: a pool already exists for this plate' }

    def self.library_name(plate_barcode, pool)
      return nil if plate_barcode.nil? || pool.nil?

      "#{plate_barcode}-#{pool}"
    end

    def plate_barcode
      name.delete_suffix("-#{pool}")
    end

    def tube_barcode
      return nil if container_material.nil? || !container_material.container.is_a?(::Tube)

      container_material.container.barcode
    end
  end
end
