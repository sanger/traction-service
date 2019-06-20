# frozen_string_literal: true

# Pipelines
module Pipelines
  # InstanceMethodCreator
  module InstanceMethodCreator
    def create_instance_method(key, &block)
      self.class.send(:define_method, key, block)
    end
  end

  def self.configure(pipelines)
    configuration = Configuration.new(pipelines)
    configuration.pipelines.each do |pipeline|
      # TODO: how do I use the create_instance_method method
      self.class.send(:define_method, pipeline, proc { configuration.send(pipeline) })
    end
    configuration
  end
end
