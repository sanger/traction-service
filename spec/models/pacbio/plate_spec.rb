# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::Plate, type: :model, pacbio: true do
  let!(:version10) { create(:pacbio_smrt_link_version10) }
  let!(:version11) { create(:pacbio_smrt_link_version11) }

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_plate }

    it_behaves_like 'uuidable'
  end

  it 'must have a run' do
    expect(build(:pacbio_plate, run: nil)).not_to be_valid
  end

  describe '#all_wells_have_pools?' do
    it 'all with pools' do
      plate = create(:pacbio_plate, wells: create_list(:pacbio_well_with_pools, 2))
      expect(plate).to be_all_wells_have_pools
    end

    it 'some with pools' do
      plate = create(:pacbio_plate,
                     wells: create_list(:pacbio_well_with_pools, 2) + create_list(:pacbio_well, 2))
      expect(plate).not_to be_all_wells_have_pools
    end

    it 'none with pools' do
      plate = create(:pacbio_plate, wells: create_list(:pacbio_well, 2))
      expect(plate).not_to be_all_wells_have_pools
    end

    it 'with no wells at all' do
      plate = create(:pacbio_plate)
      expect(plate).not_to be_all_wells_have_pools
    end
  end
end
