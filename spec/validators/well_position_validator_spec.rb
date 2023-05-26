# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WellPositionValidator do
  before do
    create(:pacbio_smrt_link_version, name: 'v12_revio', default: true)
  end

  # This should not throw an error
  it 'when there are no wells' do
    plate = build(:pacbio_plate, well_count: 0)
    described_class.new.validate(plate.run)
    expect(plate.run.errors.full_messages).to be_empty
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

    describe 'contiguousness' do
      it 'B1 filled' do
        plate.wells = [build(:pacbio_well, row: 'B', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors).to be_empty
      end

      it 'B1, C1 filled' do
        plate.wells = [build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'C', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors).to be_empty
      end

      it 'C1 filled' do
        plate.wells = [build(:pacbio_well, row: 'C', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors).to be_empty
      end

      it 'C1, D1 filled' do
        plate.wells = [build(:pacbio_well, row: 'C', column: '1'), build(:pacbio_well, row: 'D', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors).to be_empty
      end

      it 'D1 filled' do
        plate.wells = [build(:pacbio_well, row: 'D', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors).to be_empty
      end

      it 'A1, D1 filled' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'D', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'A1, C1 filled' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'C', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'B1, D1 filled' do
        plate.wells = [build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'D', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'A1, C1, D1 filled' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'C', column: '1'), build(:pacbio_well, row: 'D', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'A1, B1, D1 filled' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'D', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'B1, D1 filled but in reverse order' do
        plate.wells = [build(:pacbio_well, row: 'D', column: '1'), build(:pacbio_well, row: 'B', column: '1')]
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end

      it 'wont validate wells that are marked for destruction' do
        plate.wells = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1'), build(:pacbio_well, row: 'C', column: '1')]
        plate.save
        plate.reload
        plate.wells.select { |well| well.row == 'B' && well.column == '1' }.first.mark_for_destruction
        described_class.new.validate(plate.run)
        expect(plate.run.errors.full_messages.length).to eq(1)
      end
    end
  end
end
