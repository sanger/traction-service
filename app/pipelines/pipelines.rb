# frozen_string_literal: true

# Pipelines
# A Pipeline is a series of steps that are required to prepare sample material
# for sequencing
module Pipelines
  # In a number of models we associate records with a pipeline, via an enum
  # In order to maintain consistent numbering, this has been pulled out into
  # a constant. Please do *not* remove entries from this list, as it could
  # result in legacy data being reassigned to the incorrect pipelines
  ENUMS = { pacbio: 0, ont: 1, saphyr: 2 }.freeze
  HANDLERS = {
    pacbio: Pacbio,
    ont: Ont,
    saphyr: Saphyr
  }.with_indifferent_access.freeze

  def self.handler(pipeline)
    HANDLERS.fetch(pipeline) do
      raise "Unknown pipeline #{pipeline}"
    end
  end

  # InstanceMethodCreator
  module InstanceMethodCreator
    # Creates an instance method in the included class
    # @param key [String] the name of the method to be defined
    # @param block [Block] the body of the method to be defined
    def create_instance_method(key, &block)
      self.class.send(:define_method, key, block)
    end
  end

  # create methods for each pipeline so can use Pipelines.pipeline_name
  # instead of Pipelines.configuration.pipeline_name
  Rails.configuration.pipelines.each do |k, _v|
    self.class.send(:define_method, k, proc { configuration.send(k) })
  end

  # Creates a configuration instance which is attached to the module as a class method
  # e.g. Pipelines.pacbio
  # @param pipelines [Hash] list of all the pipelines with their respective
  # configuration
  # not necessary for production but useful to reload configuration for transparency purposes
  def self.configure(pipelines)
    Configuration.new(pipelines).tap do |configuration|
      configuration.pipelines.each do |pipeline|
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

  def self.load_yaml
    YAML.load_file('config/pipelines.yml')[Rails.env].symbolize_keys
  end

  # memoization. Will load configuration on first use
  def self.configuration
    @configuration ||= Configuration.new(load_yaml)
  end
end
