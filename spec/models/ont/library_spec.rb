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

  it 'name must be unique' do
    library = create(:ont_library)
    new_library = build(:ont_library, name: library.name)
    expect(new_library).to_not be_valid
    expect(new_library.errors.full_messages).to contain_exactly('Name must be unique: a pool already exists for this plate')
  end
  
  it 'does not delete associated requests on destroy' do
    library = create(:ont_library)
    num_requests = 3
    library.requests = create_list(:ont_request, num_requests)
    # sanity check
    expect(Ont::Library.count).to eq(1)
    expect(Ont::Request.count).to eq(num_requests)
    library.destroy
    expect(Ont::Library.count).to eq(0)
    expect(Ont::Request.count).to eq(num_requests)
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

  context 'resolved' do
    context 'instance' do
      it 'returns a single library' do
        library = create(:ont_library_with_requests)
        expect(library.resolved_library).to eq(library)
      end
    end

    context 'class' do
      it 'returns expected includes_args' do
        expect(Ont::Library.includes_args).to eq([
          flowcell: Ont::Flowcell.includes_args(except: :library),
          requests: Ont::Request.includes_args(except: :library)
        ])
      end

      it 'removes requests from includes_args' do
        expect(Ont::Library.includes_args(except: :requests)).to eq([flowcell: Ont::Flowcell.includes_args(except: :library)])
      end
  
      it 'removes flowcell from includes_args' do
        expect(Ont::Library.includes_args(except: :flowcell)).to eq([requests: Ont::Request.includes_args(except: :library)])
      end

      it 'returns a single library' do
        library = create(:ont_library_with_requests)
        expect(Ont::Library.resolved_library(id: library.id)).to eq(library)
      end

      it 'returns all libraries' do
        libraries = create_list(:ont_library_with_requests, 3)
        expect(Ont::Library.all_resolved_libraries).to match_array(libraries)
      end
    end
  end
end
