# frozen_string_literal: true

# TODO: would this just be better as an included method in the pool model
module Pacbio
  # PoolFactory
  # This is very simple
  # we could do this in the model but then we would need
  # nested_attributes_for which creates complexity
  # I also suspect that this will get more complicated
  class PoolFactory
    include ActiveModel::Model

    validate :check_pool

    def initialize(attributes = {})
      pool.libraries = attributes[:libraries].try(:collect) do |library|
        Pacbio::Library.new(library)
      end || []
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
      # we need to cascade the errors up to the current error object
      # otherwise it will look like there are no errors
      check_pool
      false
    end

    private

    def check_pool
      return if pool.valid?

      pool.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
