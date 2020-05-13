require 'rails_helper'

RSpec.describe Pacbio::Plate, type: :model, pacbio: true do

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_plate }
    it_behaves_like 'uuidable'
  end

  it 'must have a run' do
    expect(build(:pacbio_plate, run: nil)).to_not be_valid
  end
  
end