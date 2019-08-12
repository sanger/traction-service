require "rails_helper"

RSpec.describe Saphyr::Chip, type: :model, saphyr: true do

  let(:barcode) { 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX' }
  let(:serial_number) { 'FLEVEAOLPTOWPNWU' }

  it 'must have a barcode' do
    expect(build(:saphyr_chip, barcode: nil)).to_not be_valid
  end

  context 'run' do
    it 'can belong to a run' do
      run = create(:saphyr_run)
      expect(create(:saphyr_chip, run: run)).to be_valid
    end

    it 'doesnt have to belong to a run' do
      expect(build(:saphyr_chip, run: nil)).to be_valid
    end

    it 'can have a run' do
      run = create(:saphyr_run)
      expect(create(:saphyr_chip, run: run).run).to eq run
    end
  end

  context 'barcode' do
    it 'must have a barcode' do
      expect(build(:saphyr_chip, barcode: barcode)).to be_valid
      expect(build(:saphyr_chip, barcode: nil)).to_not be_valid
    end

    it 'must have a barcode of 16 characters or more' do
      expect(build(:saphyr_chip, barcode: serial_number)).to be_valid
      expect(build(:saphyr_chip, barcode: 'smashit')).to_not be_valid
    end

    context 'serial number' do

      it 'will be updated when the barcode is updated' do
        chip = create(:saphyr_chip, barcode: 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX')
        expect(chip.serial_number).to eq 'FLEVEAOLPTOWPNWU'
      end

    end
  end

end
