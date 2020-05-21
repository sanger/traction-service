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
    context 'instance' do
      it 'returns a single well' do
        well = create(:well_with_tagged_ont_requests)
        expect(well.resolved_well).to eq(well)
      end
    end

    context 'class' do
      it 'returns expected includes_args' do
        expect(Well.includes_args).to eq([
          container_materials: :material,
          plate: Plate.includes_args(:wells)
        ])
      end

      it 'removes plate from includes_args' do
        expect(Well.includes_args(:plate)).to eq([container_materials: :material])
      end
  
      it 'removes container_materials from includes_args' do
        expect(Well.includes_args(:container_materials)).to eq([plate: Plate.includes_args(:wells)])
      end

      it 'returns a single well' do
        well = create(:well_with_tagged_ont_requests)
        expect(Well.resolved_well(id: well.id)).to eq(well)
      end

      it 'returns all wells' do
        wells = create_list(:well_with_tagged_ont_requests, 3)
        expect(Well.all_resolved_wells).to match_array(wells)
      end
    end
  end
end
