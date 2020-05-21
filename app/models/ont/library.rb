# frozen_string_literal: true

module Ont
  # Ont::Library
  class Library < ApplicationRecord
    include Material

    has_many :requests, foreign_key: :ont_library_id,
                        inverse_of: :library, dependent: :nullify
    has_one :flowcell, foreign_key: :ont_library_id, inverse_of: :library, dependent: :destroy

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

    def resolved_library
      self.class.resolved_query.find(id)
    end

    def self.includes_args(except = nil)
      if except == :requests
        [ flowcell: Ont::Flowcell.includes_args(:library) ]
      elsif except == :flowcell
        [ requests: Ont::Request.includes_args(:library) ]
      else
        [ flowcell: Ont::Flowcell.includes_args(:library), requests: Ont::Request.includes_args(:library) ]
      end
    end

    def self.resolved_library(id:)
      resolved_query.find(id)
    end

    def self.all_resolved_libraries
      resolved_query.all
    end

    def self.resolved_query
      Ont::Library.includes(*includes_args)
    end
  end
end
