# frozen_string_literal: true

# RunFactory
class RunFactory
  include ActiveModel::Model

  def initialize(attributes = [])
    attributes.each { |run| runs << Run.new(run.merge!(chip: Chip.new)) }
  end

  def runs
    @runs ||= []
  end

  def save
    return false unless valid?

    runs.collect(&:save)
    true
  end
end
