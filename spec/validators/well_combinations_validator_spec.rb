# frozen_string_literal: true

require 'rails_helper'

class WellList
  include ActiveModel::Model

  attr_accessor :positions

  def wells
    @wells ||= positions.map do |position|
      WellItem.new(position:)
    end
  end

  class WellItem
    include ActiveModel::Model

    attr_accessor :position

    def mark_for_destruction
      @marked_for_destruction = true
    end

    def marked_for_destruction?
      @marked_for_destruction
    end
  end
end

RSpec.describe WellCombinationsValidator do
  let(:valid_combinations) { [['A1'], %w[A1 B1], %w[A1 B1 C1], %w[A1 B1 C1 D1], ['B1'], %w[B1 C1], %w[B1 C1 D1], ['C1'], %w[C1 D1], ['D1']] }
  let(:invalid_combinations) { [%w[A1 D1], %w[A1 C1], %w[B1 D1], %w[A1 C1 D1], %w[A1 B1 D1]] }
  let(:validator) { described_class.new(valid_combinations:, exclude_marked_for_destruction: true) }

  it 'is valid when it is a valid well combination' do
    valid_combinations.each do |valid_combination|
      well_list = WellList.new(positions: valid_combination)
      validator.validate(well_list)
      expect(well_list.errors).to be_empty
    end
  end

  it 'is valid when the well combination is reversed but still a valid combination' do
    valid_combinations.each do |valid_combination|
      well_list = WellList.new(positions: valid_combination.reverse)
      validator.validate(well_list)
      expect(well_list.errors).to be_empty
    end
  end

  it 'is invalid when it is an invalid well combination' do
    invalid_combinations.each do |invalid_combination|
      well_list = WellList.new(positions: invalid_combination)
      validator.validate(well_list)
      invalid_order = invalid_combination.join(',')
      expect(well_list.errors[:wells]).to include("must be in a valid order, currently #{invalid_order}")
    end
  end

  it 'does not validate wells that are marked for destruction' do
    well_list = WellList.new(positions: %w[A1 D1])
    well_list.wells.last.mark_for_destruction
    validator.validate(well_list)
    expect(well_list.errors).to be_empty
  end
end
