# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Well, type: :model do
  it_behaves_like 'container'

  it 'must have plate' do
    expect(build(:well, plate: nil)).to_not be_valid
  end

  it 'must have a position' do
    expect(build(:well, position: nil)).to_not be_valid
  end

  it 'gets row from position' do
    well = create(:well, position: 'B6')
    expect(well.row).to eq('B')
  end

  it 'gets column from position' do
    well = create(:well, position: 'B6')
    expect(well.column).to eq(6)
  end

  it 'gets two digit column from position' do
    well = create(:well, position: 'B12')
    expect(well.column).to eq(12)
  end

  context 'resolved' do
    it 'returns expected includes_args' do
      expect(Well.includes_args.flat_map(&:keys)).to contain_exactly(:container_materials, :plate)
    end

    it 'removes plate from includes_args' do
      expect(Well.includes_args(:plate).flat_map(&:keys)).to_not include(:plate)
    end

    it 'removes container_materials from includes_args' do
      expect(Well.includes_args(:container_materials).flat_map(&:keys))
        .to_not include(:container_materials)
    end
  end
end
