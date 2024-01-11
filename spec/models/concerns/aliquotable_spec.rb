# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Aliquotable do
  describe '#primary_aliquot' do
    it 'returns the primary aliquot' do
      pacbio_pool = create(:pacbio_pool)
      aliquot = create(:aliquot, aliquot_type: :primary, source: pacbio_pool)
      expect(pacbio_pool.primary_aliquot).to eq aliquot
    end

    # Should this error instead?
    it 'returns nil if there are no primary aliquots' do
      pacbio_pool = create(:pacbio_pool)
      expect(pacbio_pool.primary_aliquot).to be_nil
    end
  end

  describe '#derived_aliquot' do
    it 'returns the derived aliquots' do
      pacbio_pool = create(:pacbio_pool)
      aliquots = create_list(:aliquot, 5, aliquot_type: :derived, source: pacbio_pool)
      expect(pacbio_pool.derived_aliquots).to eq aliquots
    end

    # Should this error instead?
    it 'returns nil if there are no primary aliquots' do
      pacbio_pool = create(:pacbio_pool)
      expect(pacbio_pool.derived_aliquots).to eq []
    end
  end
end
