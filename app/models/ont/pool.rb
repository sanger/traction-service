# frozen_string_literal: true

module Ont
  # Pool
  class Pool < ApplicationRecord
    belongs_to :tube, default: -> { Tube.new }

    has_many :libraries, class_name: 'Ont::Library', foreign_key: :ont_pool_id,
                          dependent: :destroy, inverse_of: :pool
    has_many :requests, through: :libraries
    # This is dependent on the requests association, so needs to be included
    # after that is defined
    include PlateSourcedLibrary
    validates :volume, :kit_number, numericality: { greater_than_or_equal_to: 0, allow_nil: true }, presence: true
    validates :libraries, presence: true
    validates_with TagValidator

    def library_attributes=(library_options)
      self.libraries = library_options.map do |attributes|
        if attributes['id']
          update_library(attributes)
        else
          Ont::Library.new(attributes)
        end
      end
    end

    private

    def update_library(attributes)
      id = attributes['id'].to_s
      indexed_libraries.fetch(id) { missing_library(id) }
                        .tap { |l| l.update(attributes) }
    end

    def missing_library(id)
      raise ActiveRecord::RecordNotFound, "Ont request #{id} is not part of the pool"
    end

    def indexed_libraries
      @indexed_libraries ||= libraries.index_by { |lib| lib.id.to_s }
    end
  end
end
  