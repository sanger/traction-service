RSpec.shared_examples "labware" do

  it 'when the barcode does exist' do
    labware = create(labware_model, barcode: 'DN1234567')
    expect(labware.barcode).to eq('DN1234567')
  end

  it 'when the barcode does not exist' do
    labware = create(labware_model)
    expect(labware.barcode).to be_present
    expect(labware.barcode).to eq("TRAC-#{described_class.prefix}-#{labware.id}")
  end

end
