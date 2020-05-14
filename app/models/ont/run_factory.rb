# frozen_string_literal: true

# Ont namespace
module Ont
  # RunFactory
  # Creates or updates a run from a list of flowcell metadata.
  class RunFactory
    include ActiveModel::Model

    validate :check_run

    def initialize(flowcell_specs = [], run = nil)
      @run = run || Ont::Run.new
      build_flowcells(flowcell_specs)
    end

    attr_reader :run

    def save(**options)
      return false unless options[:validate] == false || valid?

      run.save(validate: false)
      true
    end

    private

    def build_flowcells(flowcell_specs)
      run.flowcells.clear

      flowcell_specs.each do |flowcell_spec|
        # The flowcell requires a library, so if a library does not exist
        # the flowcell, and therefore factory, will be invalid.
        library = Ont::Library.find_by(name: flowcell_spec[:library_name])
        run.flowcells.build(position: flowcell_spec[:position], run: run, library: library)
      end
    end

    def check_run
      errors.add('run', 'was not created') if run.nil?

      return if run.valid?

      run.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
