# frozen_string_literal: true

require 'rails_helper'
require 'models/concerns/material_spec'

RSpec.describe Sample, type: :model do

  context 'polymorphic behavior' do
    it_behaves_like "material"
  end

  context 'on creation' do
    it 'should be active' do
      expect(create(:sample)).to be_active
    end

    describe 'name' do
      it 'should have a name' do
        expect(create(:sample, name: 'mysample').name).to eq('mysample')
      end

      it 'must have a unique name' do
        sample = create(:sample)
        expect(build(:sample, name: sample.name)).not_to be_valid
      end

      it 'is not valid without a name' do
        expect(build(:sample, name: nil)).not_to be_valid
      end
    end

    describe 'state' do
      it 'should have a state' do
        expect(create(:sample, state: 'started').state).to eq('started')
      end

      it 'should be set on creation' do
        expect(create(:sample_with_no_state).state).to eq('started')
      end
    end

    describe 'sequencescape_request_id' do
      it 'should have a sequencescape_request_id' do
        expect(create(:sample, sequencescape_request_id: 123).sequencescape_request_id).to eq(123)
      end

      it 'is not valid without a sequencescape_request_id' do
        expect(build(:sample, sequencescape_request_id: nil)).not_to be_valid
      end
    end

    describe 'species' do
      it 'should have a species' do
        expect(create(:sample, species: 'human').species).to eq('human')
      end

      it 'is not valid without a species' do
        expect(build(:sample, species: nil)).not_to be_valid
      end
    end

    it 'should be active' do
      expect(create(:sample)).to be_active
    end
  end

  context 'on update' do
    it 'name cannot be updated' do
      sample = create(:sample)
      name = sample.name
      sample.update_attributes(name: 'sample3')
      expect(sample.reload.name).to eq(name)
    end
  end

  context 'libraries' do
    it 'can have libraries' do
      sample = create(:sample)
      lib1 = create(:library, sample: sample)
      lib2 = create(:library, sample: sample)
      expect(sample.libraries.length).to eq 2
    end
  end

end
