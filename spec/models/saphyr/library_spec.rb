require "rails_helper"

RSpec.describe Saphyr::Library, type: :model do

  context 'polymorphic behavior' do
    it_behaves_like "material"
  end

  context 'on creation' do
    it 'should be active' do
      sample = create(:sample)
      expect(create(:saphyr_library, sample: sample)).to be_active
    end

    it 'should set state to pending' do
      expect(create(:library_no_state).state).to eq('pending')
    end

    it 'should have a sample' do
      sample = create(:sample)
      expect(create(:saphyr_library, sample: sample).sample).to eq(sample)
      expect(create(:saphyr_library, sample: sample).sample_id).to eq(sample.id)
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
    it 'is not valid withoutan sample' do
      expect(build(:saphyr_library, sample: nil)).not_to be_valid
    end

    it 'is not valid withoutan enzyme' do
      expect(build(:saphyr_library, enzyme: nil)).not_to be_valid
    end
  end

  context 'deactivate' do
    it 'can be deactivated' do
      sample = create(:sample)
      library = create(:saphyr_library, sample: sample)
      expect(library.deactivate).to eq true
      expect(library.deactivated_at).to be_present
      expect(library).not_to be_active
    end

    it 'returns false if already deactivated' do
      sample = create(:sample)
      library = create(:saphyr_library, sample: sample)
      library.deactivate
      expect(library.deactivate).to eq false
    end

  end

  context 'scope' do
    context 'active' do
      it 'should return only active libraries' do
        library = create(:saphyr_library)
        library = create(:saphyr_library)
        library = create(:saphyr_library, deactivated_at: DateTime.now)
        expect(Saphyr::Library.active.length).to eq 2
      end
    end

  end
end
