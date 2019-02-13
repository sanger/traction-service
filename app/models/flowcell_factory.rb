# frozen_string_literal: true

# FlowcellFactory
class FlowcellFactory
  include ActiveModel::Model

  def initialize(attributes = [])
    debugger
    attributes.each { |flowcell| flowcells << Flowcell.new(flowcell) }
  end

  def flowcells
    @flowcells ||= []
  end

  def save
    return false unless valid?

    flowcells.collect(&:save)
    true
  end

end
