# frozen_string_literal: true

# RunFactory
class RunFactory
  include ActiveModel::Model

  # TODO: the barcode will need to be removed once
  # the ui is refactored to build a new run with validation
  def initialize(attributes = [])
    attributes.each do |run|
      runs << Run.new(run.merge!(chip: Chip.new(
        barcode: 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX'
      )))
    end
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
