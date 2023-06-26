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

RSpec.describe WellPositionsValidator do
  let(:valid_positions) { %w[A1 A2 A3 A4 A5 A6 A7 A8] }

  it 'is valid when all well positions are present' do
    well_list = WellList.new(positions: valid_positions)
    validator = described_class.new(valid_positions:)
    validator.validate(well_list)
    expect(well_list.errors).to be_empty
  end

  it 'is invalid when a well position is missing' do
    %w[B1 D2 F3 H4].each do |position|
      well_list = WellList.new(positions: valid_positions + [position])
      validator = described_class.new(valid_positions:)
      validator.validate(well_list)
      expect(well_list.errors[:wells]).to include("must be in positions #{valid_positions.join(',')}")
    end
  end

  it 'will not validate wells that are marked for destruction' do
    well_list = WellList.new(positions: valid_positions + ['B1'])
    validator = described_class.new(valid_positions:,  exclude_marked_for_destruction: true)
    well_list.wells.last.mark_for_destruction
    validator.validate(well_list)
    expect(well_list.errors).to be_empty
  end
end
