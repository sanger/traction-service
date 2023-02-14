# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sample do
  context 'on creation' do
    it 'is active' do
      expect(create(:sample)).to be_active
    end

    describe 'name' do
      it 'has a name' do
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

    describe 'external_id' do
      it 'has a external_id' do
        uuid = SecureRandom.uuid
        expect(create(:sample, external_id: uuid).external_id).to eq(uuid)
      end

      it 'is not valid without a external_id' do
        expect(build(:sample, external_id: nil)).not_to be_valid
      end
    end

    describe 'species' do
      it 'has a species' do
        expect(create(:sample, species: 'human').species).to eq('human')
      end

      it 'is not valid without a species' do
        expect(build(:sample, species: nil)).not_to be_valid
      end
    end

    it 'is active' do
      expect(create(:sample)).to be_active
    end
  end

  context 'on update' do
    it 'name cannot be updated' do
      sample = create(:sample)
      name = sample.name
      sample.update(name: 'sample3')
      expect(sample.reload.name).to eq(name)
    end
  end

  context 'requests' do
    it 'can have requests' do
      sample = create(:sample)
      libraries = create_list(:request, 2, sample:)
      expect(sample.requests.length).to eq 2
    end
  end
end
