# frozen_string_literal: true

# Ont namespace
module Ont
  # RunFactory
  # The factory will create runs from a list of libraries
  class RunFactory
    include ActiveModel::Model

    validate :check_run, :check_flowcells

    def initialize(attributes = [])
      @flowcells = []
      build_run(attributes)
    end

    attr_reader :run

    def save(**options)
      return false unless options[:validate] == false || valid?

      @run.save(validate: false)
      @flowcells.each { |flowcell| flowcell.save(validate: false) }
      true
    end

    private

    attr_reader :flowcells

    def build_run(attributes)
      constants_accessor = Pipelines::ConstantsAccessor.new(Pipelines.ont.covid)
      @run = Ont::Run.new(instrument_name: constants_accessor.instrument_name)
      attributes.each do |flowcell_spec|
        # the flowcell requires a library, so if a library does not exist
        # the flowcell, and therefore factory, will be invalid
        library = Ont::Library.find_by(name: flowcell_spec[:library_name])
        @flowcells << Ont::Flowcell.new(position: flowcell_spec[:position], run: run, library: library)
      end
    end

    def check_run
      errors.add('run', 'was not created') if @run.nil?

      return if @run.valid?

      @run.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def check_flowcells
      @flowcells.each do |flowcell|
        next if flowcell.valid?

        flowcell.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end
