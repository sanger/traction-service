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

  context 'tag set name' do
    it 'returns nil for no library requests' do
      library = create(:ont_library)
      expect(library.tag_set_name).to be_nil
    end

    it 'returns first library request tag set name' do
      library = create(:ont_library)
      library_request_1 = create(:ont_library_request, library: library)
      library_request_2 = create(:ont_library_request, library: library)
      expect(library.tag_set_name).to eq(library_request_1.tag.tag_set_name)
    end
  end

  context 'tube barcode' do
    it 'returns nil for no container material' do
      library = create(:ont_library)
      expect(library.tube_barcode).to be_nil
    end

    it 'returns nil if container is not a tube' do
      library = create(:ont_library)
      create(:container_material, container: create(:well), material: library)
      expect(library.tube_barcode).to be_nil
    end

    it 'returns tube barcode' do
      library = create(:ont_library)
      tube = create(:tube)
      create(:container_material, container: tube, material: library)
      expect(library.tube_barcode).to eq(tube.barcode)
    end
  end
end
