# frozen_string_literal: true

# Pipelines
# A Pipeline is a series of steps that are required to prepare sample material
# for sequencing
module Pipelines
  # InstanceMethodCreator
  module InstanceMethodCreator
    # Creates an instance method in the included class
    # @param key [String] the name of the method to be defined
    # @param block [Block] the body of the method to be defined
    def create_instance_method(key, &block)
      self.class.send(:define_method, key, block)
    end
  end

  # Creates a configuration instance which is attached to the module as a class method
  # e.g. Pipelines.pacbio
  # @param pipelines [Hash] list of all the pipelines with their respective
  # configuration
  def self.configure(pipelines)
    Configuration.new(pipelines).tap do |configuration|
      configuration.pipelines.each do |pipeline|
        # TODO: how do I use the create_instance_method method
        self.class.send(:define_method, pipeline, proc { configuration.send(pipeline) })
      end
    end
  end

  # Finds the pipeline configuration module based on its name
  # synctatic sugar for send
  # @param pipeline [String] name of the pipeline to be found
  def self.find(pipeline)
    send(pipeline.to_s.downcase)
  end
end
