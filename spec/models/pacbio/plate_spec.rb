# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::Plate, pacbio: true do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
  end

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_plate }

    it_behaves_like 'uuidable'
  end

  it 'must have a run' do
    expect(build(:pacbio_plate, run: nil)).not_to be_valid
  end

  it 'must have a sequencing kit box barcode' do
    expect(build(:pacbio_plate, sequencing_kit_box_barcode: nil)).not_to be_valid
  end

  it 'must have a plate number' do
    expect(build(:pacbio_plate, plate_number: nil)).not_to be_valid
  end
end
