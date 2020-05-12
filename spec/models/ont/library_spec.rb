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

  it 'must have a pool_size' do
    library = build(:ont_library, pool_size: nil)
    expect(library).to_not be_valid
  end

  context 'library name' do
    it 'returns nil with nil plate_barcode' do
      name = Ont::Library.library_name(nil, 2)
      expect(name).to be_nil
    end

    it 'returns nil with nil pool' do
      name = Ont::Library.library_name("PLATE-1234", nil)
      expect(name).to be_nil
    end

    it 'returns expected name' do
      name = Ont::Library.library_name("PLATE-1234", 2)
      expect(name).to eq("PLATE-1234-2")
    end
  end

  context 'plate barcode' do
    it 'returns expected plate barcode' do
      library = create(:ont_library)
      expect(library.plate_barcode).to eq("PLATE-1-123456")
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
