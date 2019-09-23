require "rails_helper"

RSpec.describe Saphyr::Library, type: :model, saphyr: true do

  context 'polymorphic behavior' do
    it_behaves_like "material"
  end

  context 'library' do
    let(:library_factory) { :saphyr_library }
    let(:library_model)   { Saphyr::Library}

    it_behaves_like 'library'
  end

  context 'on creation' do

    let(:request) { create(:saphyr_request)}

    it 'should have a request' do
      expect(create(:saphyr_library, request: request).request).to eq(request)
    end

    it 'should have a enzyme' do
      enzyme = create(:saphyr_enzyme)
      expect(create(:saphyr_library, enzyme: enzyme).enzyme).to eq(enzyme)
      expect(create(:saphyr_library, enzyme: enzyme).saphyr_enzyme_id).to eq(enzyme.id)
    end

    context 'tube' do
      it 'can be initialised without a tube' do
        expect(create(:saphyr_library)).to be_valid
      end

      it 'can be initialised with a tube' do
        library = create(:saphyr_library)
        tube = create(:tube, material: library)
        expect(library.tube).to eq tube
      end
    end

    context 'flowcell' do
      it 'can have a flowcell' do
        library = create(:saphyr_library)
        flowcell = create(:saphyr_flowcell, library: library)
        expect(library.flowcells).to eq [flowcell]
      end

      it 'doesnt have to have a flowcell' do
        expect(create(:saphyr_library)).to be_valid
      end
    end
  end

  context 'validation' do
    it 'is not valid without a request' do
      expect(build(:saphyr_library, request: nil)).not_to be_valid
    end

    it 'is not valid without an enzyme' do
      expect(build(:saphyr_library, enzyme: nil)).not_to be_valid
    end
  end

end
