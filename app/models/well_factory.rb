# frozen_string_literal: true

# WellFactory
# The factory will build a well
class WellFactory
  include ActiveModel::Model

  validate :check_well

  def initialize(attributes = {})
    @well = Well.new(attributes.extract!(:plate, :position))
  end

  attr_reader :well

  def save
    return false unless valid?

    well.save
    true
  end

  private

  def check_well
    return if well.valid?

    well.errors.each do |k, v|
      errors.add(k, v)
    end
  end
end
