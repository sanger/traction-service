# frozen_string_literal: true

module Ont
  # Ont::Library
  class Library < ApplicationRecord
    include Material

    has_many :requests, foreign_key: :ont_library_id,
                        inverse_of: :library, dependent: :nullify
    has_one :flowcell, foreign_key: :ont_library_id, inverse_of: :library, dependent: :destroy

    # This is dependent on the requests association, so needs to be included
    # after that is defined
    include PlateSourcedLibrary

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

    def assigned_to_flowcell
      !!flowcell
    end

    def self.includes_args(except = nil)
      args = []
      args << { flowcell: Ont::Flowcell.includes_args(:library) } unless except == :flowcell
      args << { requests: Ont::Request.includes_args(:library) } unless except == :requests

      args
    end

    def self.resolved_query
      Ont::Library.includes(*includes_args)
    end
  end
end
