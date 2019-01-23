require "rails_helper"
require 'models/concerns/material_spec'

RSpec.describe Library, type: :model do

  context 'polymorphic behavior' do
    it_behaves_like "material"
  end

  context 'on creation' do
    it 'should be active' do
      sample = create(:sample)
      expect(create(:library, sample: sample)).to be_active
    end

    it 'should set state to pending' do
      expect(create(:library_no_state).state).to eq('pending')
    end

    it 'should have a sample' do
      sample = create(:sample)
      expect(create(:library, sample: sample).sample).to eq(sample)
      expect(create(:library, sample: sample).sample_id).to eq(sample.id)
    end

    context 'tube' do
      it 'can be initialised without a tube' do
        expect(create(:library)).to be_valid
      end

      it 'can be initialised with a tube' do
        library = create(:library)
        tube = create(:tube, material: library)
        expect(library.tube).to eq tube
      end
    end
  end

  context 'deactivate' do
    it 'can be deactivated' do
      sample = create(:sample)
      library = create(:library, sample: sample)
      library.deactivate
      expect(library.deactivated_at).to be_present
      expect(library).not_to be_active
    end

    it 'returns true if already deactivated' do
      sample = create(:sample)
      library = create(:library, sample: sample)
      library.deactivate
      expect(library.deactivate).to eq true
    end

  end

  context 'scope' do
    context 'active' do
      it 'should return only active libraries' do
        library = create(:library)
        library = create(:library)
        library = create(:library, deactivated_at: DateTime.now)
        expect(Library.active.length).to eq 2
      end
    end

  end
end
