require "rails_helper"

RSpec.describe Chip, type: :model do

  let(:barcode) { 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX' }
  let(:serial_number) { 'FLEVEAOLPTOWPNWU' }

  it 'must have a barcode' do
    expect(build(:chip, barcode: nil)).to_not be_valid
  end

  context 'run' do
    it 'can belong to a run' do
      run = create(:run)
      expect(create(:chip, run: run)).to be_valid
    end

    it 'doesnt have to belong to a run' do
      expect(build(:chip, run: nil)).to be_valid
    end

    it 'can have a run' do
      run = create(:run)
      expect(create(:chip, run: run).run).to eq run
    end
  end

  context 'barcode' do
    it 'must have a barcode' do
      expect(build(:chip, barcode: barcode)).to be_valid
      expect(build(:chip, barcode: nil)).to_not be_valid
    end

    it 'must have a barcode of 16 characters or more' do
      expect(build(:chip, barcode: serial_number)).to be_valid
      expect(build(:chip, barcode: 'smashit')).to_not be_valid
    end

    context 'serial number' do

      it 'will be updated when the barcode is updated' do
        chip = create(:chip, barcode: 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX')
        expect(chip.serial_number).to eq 'FLEVEAOLPTOWPNWU'
      end

    end
  end

end
