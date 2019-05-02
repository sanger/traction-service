# frozen_string_literal: true

require 'ostruct'

module Pipelines
  # InstanceMethodCreator
  module InstanceMethodCreator
    def create_instance_method(key, &block)
      self.class.send(:define_method, key, block)
    end
  end

  # Configuration
  class Configuration
    include InstanceMethodCreator

    def initialize(pipelines)
      pipelines.with_indifferent_access.each do |key, pipeline|
        create_instance_method(key) { Item.new(pipeline) }
      end
    end

    # Configuration::Item
    class Item
      include Enumerable
      include InstanceMethodCreator

      attr_reader :children

      def initialize(children = {})
        @children = children
        children.each do |key, child|
          if child.instance_of?(ActiveSupport::HashWithIndifferentAccess)
            create_instance_method(key) { Item.new(child) }
          else
            create_instance_method(key) { child }
          end
        end
      end

      def each(&block)
        children.each(&block)
      end
    end
  end
end
