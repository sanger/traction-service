require 'rails_helper'

RSpec.describe Pacbio::Plate, type: :model, pacbio: true do

  it 'must have a run' do
    expect(build(:pacbio_plate, run: nil)).to_not be_valid
  end
  
end