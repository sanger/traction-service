# frozen_string_literal: true

# PlateFactory
# The factory will build a plate
# A plate must have a barcode
class PlateFactory
  include ActiveModel::Model

  validate :check_plate

  def initialize(attributes)
    @plate = Plate.new(attributes.extract!(:barcode))
  end

  attr_reader :plate

  def save
    return false unless valid?

    plate.save
    true
  end

  private

  def check_plate
    if plate.nil?
      errors.add('plate', 'can not be nil')
      return
    end

    errors.add('plate', 'must have a barcode') if plate.barcode.nil?
  end
end
