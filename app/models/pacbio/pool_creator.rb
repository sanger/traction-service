# frozen_string_literal: true

# TODO: would this just be better as an included method in the pool model
module Pacbio
  # PoolFactory
  # This is very simple
  # we could do this in the model but then we would need
  # nested_attributes_for which creates complexity
  # I also suspect that this will get more complicated
  class PoolCreator
    delegate_missing_to :pool

    def initialize(libraries: [], template_prep_kit_box_barcode: nil, volume: nil, concentration: nil, fragment_size: nil)
      self.libraries = libraries
      pool.assign_attributes(
        template_prep_kit_box_barcode: template_prep_kit_box_barcode,
        volume: volume,
        concentration: concentration,
        fragment_size: fragment_size
      )
    end

    def libraries=(library_options)
      pool.libraries = library_options.map do |library|
        Pacbio::Library.new(library)
      end
    end

    def pool
      @pool ||= Pacbio::Pool.new(tube: Tube.new)
    end

    def save!
      ActiveRecord::Base.transaction do
        pool.save!
        true
      end
    rescue ActiveRecord::RecordInvalid
      false
    end
  end
end
