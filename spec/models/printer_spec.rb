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

  it 'is valid without an active status' do
    expect(build(:printer, active: nil)).to be_valid
  end

  it 'has a default active status of true' do
    expect(create(:printer).active).to be true
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
end
