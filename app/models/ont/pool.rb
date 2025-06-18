# frozen_string_literal: true

module Ont
  # Pool
  class Pool < ApplicationRecord
    include Uuidable

    belongs_to :tube, default: -> { Tube.new(barcode:) }

    attr_accessor :barcode

    # We have one-to-one association between pool and flowcell at the moment.
    # XXX: We set dependent option to nullify for the moment.
    has_one :flowcell,
            class_name: 'Ont::Flowcell',
            foreign_key: :ont_pool_id,
            inverse_of: :pool,
            dependent: :nullify

    has_many :libraries, class_name: 'Ont::Library', foreign_key: :ont_pool_id,
                         dependent: :destroy, inverse_of: :pool
    has_many :requests, through: :libraries
    # This is dependent on the requests association, so needs to be included
    # after that is defined
    include DualSourcedPool
    validates :volume, :concentration,
              :insert_size, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :libraries, presence: true
    validates_with TagValidator

    # Constants used in final_library_amount calculation
    VOLUME_CONCENTRATION_MULTIPLIER = 1_000_000
    INSERT_SIZE_MULTIPLIER = 660

    # Instead of before save we could use:
    # 'attribute :final_library_amount, default: calculate_final_library_amount'
    # But when this was tried calculate_final_library_amount wasn't accessible from the scope
    # In future this would be nice to change to use this

    before_save { self.final_library_amount = calculate_final_library_amount }

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

    def calculate_final_library_amount
      # This method calculates the resultant number of fmol in a pool
      # This saves the labs manually calculating the formula
      if concentration.present? && volume.present? && insert_size.present? && insert_size != 0
        return (
          (concentration * volume * VOLUME_CONCENTRATION_MULTIPLIER) /
          (insert_size * INSERT_SIZE_MULTIPLIER)
        ).round(1)
      end

      nil
    end
  end
end
