# frozen_string_literal: true

module Pacbio
  # PoolFactory
  class PoolFactory
    include ActiveModel::Model

    attr_accessor :libraries

    def libraries=(libraries)
      p libraries
      @libraries = libraries.collect { |library| Pacbio::Library.new(library)}
    end

  end
end
