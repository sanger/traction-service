require 'rails_helper'

RSpec.describe Ont::Library, type: :model do
  context 'material' do
    let(:material_model) { :ont_library }
    it_behaves_like 'material'
  end

  it 'must have a name' do
    library = build(:ont_library, name: nil)
    expect(library).to_not be_valid
  end

  it 'must have a pool' do
    library = build(:ont_library, pool: nil)
    expect(library).to_not be_valid
  end

  it 'must have a well_range' do
    library = build(:ont_library, well_range: nil)
    expect(library).to_not be_valid
  end

  it 'must have a pool_size' do
    library = build(:ont_library, pool_size: nil)
    expect(library).to_not be_valid
  end

  it 'must have a plate_barcode' do
    library = build(:ont_library, plate_barcode: nil)
    expect(library).to_not be_valid
  end
end
