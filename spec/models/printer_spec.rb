# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Printer do
  it 'is invalid without a name' do
    expect(build(:printer, name: nil)).not_to be_valid
  end

  it 'is invalid if the name is not unique (case insensitive)' do
    create(:printer, name: 'PrinterA')
    expect(build(:printer, name: 'printera')).not_to be_valid
  end

  it 'is invalid without a labware_type' do
    expect(build(:printer, labware_type: nil)).not_to be_valid
  end

  it 'is valid without a deactivated_at' do
    expect(build(:printer, deactivated_at: nil)).to be_valid
  end

  it 'has a default deactivated_at of nil' do
    expect(create(:printer).deactivated_at).to be_nil
  end

  it 'is active if deactivated_at is nil' do
    expect(create(:printer).active?).to be true
  end

  it 'is inactive if deactivated_at is set' do
    expect(create(:printer, deactivated_at: Time.current).active?).to be false
  end

  it 'has a valid list of labware_types' do
    expect(described_class.labware_types).to eq({ 'tube' => 0, 'plate96' => 1, 'plate384' => 2 })
  end

  it 'is valid if labware_type is in the list of labware_types' do
    expect(build(:printer, labware_type: 0)).to be_valid
  end

  it 'is invalid if labware_type is not in the list of labware_types' do
    expect { create(:printer, labware_type: 3) }.to raise_error(ArgumentError)
  end

  it 'returns active printers' do
    active_printer = create(:printer)
    create(:printer, deactivated_at: Time.current)
    expect(described_class.active).to eq([active_printer])
  end

  it 'returns inactive printers' do
    inactive_printer = create(:printer, deactivated_at: Time.current)
    create(:printer)
    expect(described_class.inactive).to eq([inactive_printer])
  end

  it 'deactivates a printer' do
    printer = create(:printer)
    expect { printer.deactivate! }.to change { printer.deactivated_at }.from(nil)
  end
end
