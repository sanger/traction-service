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

    describe 'retention_instruction' do
      it 'has a retention_instruction' do
        expect(create(:sample, retention_instruction: 'return_to_customer_after_2_years').retention_instruction).to eq('return_to_customer_after_2_years')
      end
    end
  end

  context 'on update' do
    it 'name cannot be updated' do
      sample = create(:sample)
      expect { sample.update(name: 'sample3') }.to raise_error(ActiveRecord::ReadonlyAttributeError)
    end
  end

  context 'requests' do
    it 'can have requests' do
      sample = create(:sample)
      create_list(:request, 2, sample:)
      expect(sample.requests.length).to eq 2
    end
  end

  context 'retention instructions validations' do
    it 'can have nil values' do
      expect(build(:sample, retention_instruction: nil)).to be_valid
    end

    it 'cannot have any value other than what is specified' do
      expect { build(:sample, retention_instruction: 'invalid_instruction') }.to raise_error(ArgumentError)
    end
  end

  context 'after create' do
    describe 'retention instructions' do
      let(:sample1) { create(:sample, retention_instruction: 'destroy_after_2_years') }
      let(:sample2) { create(:sample, retention_instruction: 'return_to_customer_after_2_years') }
      let(:sample3) { create(:sample, retention_instruction: 'long_term_storage') }

      it 'has the correct retention instruction value in the database' do
        expect(sample1.reload.retention_instruction_before_type_cast).to eq(0)
        expect(sample2.reload.retention_instruction_before_type_cast).to eq(1)
        expect(sample3.reload.retention_instruction_before_type_cast).to eq(2)
      end
    end
  end
end
