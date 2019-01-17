require "rails_helper"
require 'models/concerns/material_spec'

RSpec.describe Library, type: :model do

  context 'polymorphic behavior' do
    it_behaves_like "material"
  end

  context 'on creation' do
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
        expect(create(:library_with_tube).tube).to be_valid
        expect(create(:library_with_tube).tube).to be_present
      end
    end
  end

end
