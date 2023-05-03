# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WellPositionValidator do
  before do
    create(:pacbio_smrt_link_version, name: 'v12_revio', default: true)
  end

  describe 'well locations' do
    let!(:plate) { create(:pacbio_plate) }

    describe 'positioning' do
      it 'when there is a single well in the correct position' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages).to be_empty
      end

      it 'when there are two wells in the correct position' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages).to be_empty
      end

      it 'when there are three wells in the correct position' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'C', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages).to be_empty
      end

      it 'when there are four wells in the correct position' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'C', column: '1'), build(:pacbio_well, row: 'D', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages).to be_empty
      end

      it 'when there is a single well not in the correct position' do
        plate.wells = [build(:pacbio_well, row: 'G', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'when there are two wells one of which is not in the correct position' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'G', column: '12')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'when there are three wells one of which is not in the correct position' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'H', column: '4')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'when there are four wells two of which are not in the correct position' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'D', column: '4'), build(:pacbio_well, row: 'H', column: '12')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end
    end

    describe.skip 'contiguousness' do
      it 'A1 - empty, B1 - filled, C1 - empty, D1 - empty' do
        plate.wells = [build(:pacbio_well, row: 'B', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'A1 - filled, B1 - empty, C1 - filled, D1 - empty' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'C', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'A1 - filled, B1 - empty, C1 - empty, D1 - filled' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'D', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'A1 - empty, B1 - filled, C1 - filled, D1 - filled' do
        plate.wells = [build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'C', column: '1'), build(:pacbio_well, row: 'D', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end
    end
  end
end
