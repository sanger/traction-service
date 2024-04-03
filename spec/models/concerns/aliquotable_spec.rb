# frozen_string_literal: true

require 'rails_helper'

# These tests are tied to pool behaviour at the moment. This should be extracted to the aliquotable concern once
# Revio Multiplexing work is complete

RSpec.describe Aliquotable do
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
end
