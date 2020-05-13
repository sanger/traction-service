# frozen_string_literal: true

# Ont namespace
module Ont
  # FlowcellFactory
  # Creates flowcells from an Ont Run and an array of positions and library names.
  class FlowcellFactory
    include ActiveModel::Model

    validate :check_flowcells

    def initialize(attributes = {})
      build_flowcells(attributes)
    end

    def flowcells
      @flowcells ||= []
    end

    def save(**options)
      return false unless options[:validate] == false || valid?

      flowcells.each { |flowcell| flowcell.save(validate: false) }
      true
    end

    private

    def build_flowcells(attributes)
      attributes[:flowcell_specs].each do |flowcell_spec|
        # The flowcell requires a library, so if a library does not exist
        # the flowcell, and therefore factory, will be invalid.
        library = Ont::Library.find_by(name: flowcell_spec[:library_name])
        flowcells << Ont::Flowcell.new(position: flowcell_spec[:position],
                                       run: attributes[:run], library: library)
      end
    end

    def check_flowcells
      flowcells.each do |flowcell|
        next if flowcell.valid?

        flowcell.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end
