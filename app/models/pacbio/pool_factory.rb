# frozen_string_literal: true

module Pacbio
  # PoolFactory
  # This is very simple
  # we could do this in the model but then we would need nested_attributes_for which creates complexity
  # I also suspect that this will get more complicated
  class PoolFactory
    include ActiveModel::Model

    validate :check_pool

    def initialize(attributes = {})
      pool.libraries = attributes[:libraries].try(:collect) { |library| Pacbio::Library.new(library)} || []
    end
    
    def pool
      @pool ||= Pacbio::Pool.new(tube: Tube.new)
    end

    def save!
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
