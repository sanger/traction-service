require 'rails_helper'

RSpec.describe Plate, type: :model do

  it 'when the barcode does exist' do
    plate = create(:plate, barcode: 'DN1234567')
    expect(plate.barcode).to eq('DN1234567')
  end

  it 'when the barcode does not exist' do
    plate = create(:plate)
    expect(plate.barcode).to be_present
    expect(plate.barcode).to eq("TRAC-1-#{plate.id}")
  end
end
