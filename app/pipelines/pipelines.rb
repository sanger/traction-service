# frozen_string_literal: true

# Pipelines
# A Pipeline is a series of steps that are required to prepare sample material
# for sequencing
module Pipelines
  # In a number of models we associate records with a pipeline, via an enum
  # In order to maintain consistent numbering, this has been pulled out into
  # a constant. Please do *not* remove entries from this list, as it could
  # result in legacy data being reassigned to the incorrect pipelines
  NAMES = { pacbio: 0, ont: 1, qc_result: 3, reception: 4, extraction: 5, sample_qc: 6,
            hic: 7, bio_nano: 8 }.freeze
  HANDLERS = {
    pacbio: Pacbio,
    ont: Ont,
    qc_result: QcResult
  }.with_indifferent_access.freeze
  PIPELINES_DIR = 'config/pipelines'

  def self.handler(pipeline)
    HANDLERS.fetch(pipeline) do
      raise "Unknown pipeline #{pipeline}"
    end
  end

  # create methods for each pipeline so can use Pipelines.pipeline_name
  # instead of Pipelines.configuration.pipeline_name
  NAMES.each do |k, _v|
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

  # Load config files that match the name of a pipeline and merge them into the config hash
  def self.load_yaml
    config = {}
    Dir.glob("#{PIPELINES_DIR}/*.yml").each do |pipeline_file|
      pipeline_name = File.basename(pipeline_file, '.*')
      next unless NAMES.keys.include?(pipeline_name.to_sym)

      config.merge!(YAML.load_file(pipeline_file, aliases: true)[Rails.env].symbolize_keys)
    end
    config
  end

  # memoization. Will load configuration on first use
  def self.configuration
    @configuration ||= Configuration.new(load_yaml)
  end
end
