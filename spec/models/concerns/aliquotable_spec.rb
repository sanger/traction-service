# frozen_string_literal: true

require 'rails_helper'

# These tests are tied to pool behaviour at the moment. This should be extracted to the aliquotable concern once
# Revio Multiplexing work is complete

RSpec.describe Aliquotable do
  before do
    Flipper.enable(:y24_153__enable_volume_check_pacbio_pool_on_update)
  end

  describe '#primary_aliquot' do
    it 'returns the primary aliquot' do
      pacbio_pool = create(:pacbio_pool)
      expect(pacbio_pool.primary_aliquot).to be_present
    end

    # Should this error instead?
    it 'errors if there are no primary aliquots' do
      pacbio_pool = build(:pacbio_pool, primary_aliquot: nil)
      expect(pacbio_pool).not_to be_valid
      expect(pacbio_pool.errors[:primary_aliquot]).to include("can't be blank")
    end
  end

  describe '#derived_aliquots' do
    it 'returns the derived aliquots' do
      pacbio_pool = create(:pacbio_pool)
      aliquots = create_list(:aliquot, 5, aliquot_type: :derived, source: pacbio_pool)
      expect(pacbio_pool.derived_aliquots).to eq aliquots
    end

    # Should this error instead?
    it 'returns empty array if there are no dervied aliquots' do
      pacbio_pool = create(:pacbio_pool)
      expect(pacbio_pool.derived_aliquots).to eq []
    end
  end

  describe '#used_aliquots' do
    it 'returns the used aliquots' do
      pacbio_pool = create(:pacbio_pool)
      # Because of the save hook in the pool model the created_at attributes are slightly different
      # But we can assert the ids are the same
      expect(pacbio_pool.used_aliquots.count).to eq(1)
    end

    it 'returns empty array if there are no used_by aliquots' do
      pacbio_pool = create(:pacbio_pool)
      pacbio_pool.used_aliquots = []
      expect(pacbio_pool.used_aliquots).to eq []
    end
  end

  describe '#used_volume' do
    it 'returns the sum of the volumes of derived aliquots' do
      library = create(:pacbio_library)
      create_list(:aliquot, 5, aliquot_type: :derived, source: library, volume: 3)
      library.primary_aliquot.volume = 50
      library.save
      expect(library.used_volume).to eq(15)
    end

    it 'returns 0 if there are no derived aliquots' do
      library = create(:pacbio_library)
      expect(library.used_volume).to eq(0)
    end
  end

  describe '#available_volume' do
    it 'returns the available volume' do
      library = create(:pacbio_library)
      create_list(:aliquot, 5, aliquot_type: :derived, source: library, volume: 3)
      library.primary_aliquot.volume = 50
      library.save
      expect(library.available_volume).to eq(35)
    end
  end

  describe '#available_volume_check' do
    it 'returns true if there is enough volume' do
      library = create(:pacbio_library)
      create_list(:aliquot, 5, aliquot_type: :derived, source: library, volume: 3)
      library.primary_aliquot.volume = 50
      library.save
      expect(library.available_volume_sufficient).to be(true)
    end

    it 'returns false if there is not enough volume' do
      library = create(:pacbio_library)
      create_list(:aliquot, 5, aliquot_type: :derived, source: library, volume: 3)
      library.primary_aliquot.volume = 10
      library.save
      expect(library.available_volume_sufficient).to be(false)
    end

    it 'returns the available volume rounded to 2 decimal places' do
      library = create(:pacbio_library)
      create_list(:aliquot, 5, aliquot_type: :derived, source: library, volume: 3)
      library.primary_aliquot.volume = 50.5555
      library.save
      expect(library.available_volume).to eq(35.56) # 50.5555 - 5*3 = 35.5555 rounded to 35.56
    end
  end

  describe '#used_volume_check' do
    context 'when primary aliquot volume has increased' do
      it 'does not add any error' do
        library = build(:pacbio_library, primary_aliquot: build(:aliquot, aliquot_type: :primary, volume: 10))
        create_list(:aliquot, 4, aliquot_type: :derived, source: library, volume: 2)
        library.primary_aliquot.volume = 15
        expect(library.primary_aliquot_volume_sufficient).to be true
        expect(library.errors[:volume]).to be_empty
      end
    end

    context 'when primary aliquot volume for libraries is less than used volume' do
      it 'adds an error' do
        library = create(:pacbio_library, volume: 100, primary_aliquot: build(:aliquot, aliquot_type: :primary, volume: 10))
        create_list(:aliquot, 5, aliquot_type: :derived, source: library, volume: 2)
        library.primary_aliquot.volume = 5
        expect { library.primary_aliquot_volume_sufficient }.to throw_symbol(:abort)
        expect(library.errors[:volume]).to include('Volume must be greater than the current used volume')
      end
    end

    context 'when primary aliquot volume for pools is less than used volume' do
      it 'adds an error' do
        pool = create(:pacbio_pool, volume: 100, primary_aliquot: build(:aliquot, aliquot_type: :primary, volume: 10))
        create_list(:aliquot, 5, aliquot_type: :derived, source: pool, volume: 2)
        pool.primary_aliquot.volume = 5
        expect { pool.primary_aliquot_volume_sufficient }.to throw_symbol(:abort)
        expect(pool.errors[:volume]).to include('Volume must be greater than the current used volume')
      end
    end

    context 'when primary_aliquot volume has not changed' do
      it 'returns without checking volume' do
        library = create(:pacbio_library, volume: 100, primary_aliquot: build(:aliquot, aliquot_type: :primary, volume: 10))
        library.primary_aliquot.concentration = 5
        expect(library.primary_aliquot_volume_sufficient).to be_nil
      end
    end
  end
end
