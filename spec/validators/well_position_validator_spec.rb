# frozen_string_literal: true

require 'rails_helper'

RSpec.describe.skip WellPositionValidator do
  describe 'well locations' do
    it 'when the wells are in the correct position' do
      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'A1')])
      expect(described_class.new.validate(record)).to be_valid

      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'A1'), build(:pacbio_well, position: 'B1')])
      expect(described_class.new.validate(record)).to be_valid

      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'A1'), build(:pacbio_well, position: 'B1'), build(:pacbio_well, position: 'C1')])
      expect(described_class.new.validate(record)).to be_valid

      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'A1'), build(:pacbio_well, position: 'B1'), build(:pacbio_well, position: 'C1'), build(:pacbio_well, position: 'D1')])
      expect(described_class.new.validate(record)).to be_valid
    end

    it 'when the wells are not in the correct position' do
      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'G1')])
      expect(described_class.new.validate(record)).not_to be_valid

      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'A1'), build(:pacbio_well, position: 'G12')])
      expect(described_class.new.validate(record)).to be_valid

      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'A1'), build(:pacbio_well, position: 'B1'), build(:pacbio_well, position: 'H4')])
      expect(described_class.new.validate(record)).to be_valid

      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'A1'), build(:pacbio_well, position: 'B1'), build(:pacbio_well, position: 'D4'), build(:pacbio_well, position: 'H12')])
      expect(described_class.new.validate(record)).to be_valid
    end
  end

  describe 'contiguousness' do
    it 'when the wells are not in the correct sequence' do
      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'B1')])
      expect(described_class.new.validate(record)).not_to be_valid

      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'A1'), build(:pacbio_well, position: 'C1')])
      expect(described_class.new.validate(record)).not_to be_valid

      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'A1'), build(:pacbio_well, position: 'D1')])
      expect(described_class.new.validate(record)).not_to be_valid

      record = build(:pacbio_run, wells: [build(:pacbio_well, position: 'B1'), build(:pacbio_well, position: 'C1'), build(:pacbio_well, position: 'D1')])
      expect(described_class.new.validate(record)).not_to be_valid
    end
  end
end
