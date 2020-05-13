# frozen_string_literal: true

# Ont namespace
module Ont
  # RunFactory
  # Creates a run from a list of flowcell metadata.
  class RunFactory
    include ActiveModel::Model

    validate :check_run, :check_flowcell_factory

    def initialize(flowcell_specs = [])
      build_run(flowcell_specs)
    end

    attr_reader :run

    def save(**options)
      return false unless options[:validate] == false || valid?

      run.save(validate: false)
      flowcell_factory.save(validate: false)
      true
    end

    private

    attr_reader :flowcell_factory

    def build_run(flowcell_specs)
      @run = Ont::Run.new
      @flowcell_factory = FlowcellFactory.new(run: run, flowcell_specs: flowcell_specs)
    end

    def check_run
      errors.add('run', 'was not created') if run.nil?

      return if @run.valid?

      run.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def check_flowcell_factory
      return if flowcell_factory.valid?

      flowcell_factory.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
