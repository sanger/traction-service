# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::Request, :pacbio do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
  end

  it_behaves_like 'requestor model'

  context 'cost_code default value' do
    it 'sets cost_code to a default value if not entered' do
      request = described_class.create(library_type: 'library_type_1',
                                       estimate_of_gb_required: 10,
                                       number_of_smrt_cells: 1,
                                       external_study_id: 1)
      expect(request.cost_code).to eq(Rails.application.config.pacbio_request_cost_code) #= config value is'S4699'
    end

    it 'sets cost_code to entered value if inputted' do
      request = described_class.create(library_type: 'library_type_1',
                                       estimate_of_gb_required: 10,
                                       number_of_smrt_cells: 1,
                                       external_study_id: 1,
                                       cost_code: 'PSD123')
      expect(request.cost_code).to eq('PSD123')
    end
  end

  context 'libraries' do
    it 'can have one or more' do
      request = create(:pacbio_request)
      create_list(:pacbio_library_with_tag, 5, request:)
      expect(request.libraries.count).to eq(5)
    end
  end

  describe '#sequencing_plates' do
    it 'if the request belongs to a run' do
      plate = build(:pacbio_plate_with_wells, :pooled)
      create(:pacbio_run, plates: [plate])
      request = plate.wells.first.libraries.first.request
      expect(request.sequencing_plates).to eq([plate])
    end

    it 'when the request belongs to multiple runs' do
      plate1 = build(:pacbio_plate)
      plate2 = build(:pacbio_plate)
      create(:pacbio_run, plates: [plate1])
      create(:pacbio_run, plates: [plate2])
      request = create(:pacbio_request)
      library1 = create(:pacbio_library, request:)
      library2 = create(:pacbio_library, request:)
      pool = create(:pacbio_pool, libraries: [library1, library2])
      create(:pacbio_well, pools: [pool], plate: plate1)
      create(:pacbio_well, pools: [pool], plate: plate2)
      expect(request.sequencing_plates).to eq([plate1, plate2])
    end

    it 'when the request does not belong to any runs' do
      request = create(:pacbio_request)
      expect(request.sequencing_plates).to be_empty
    end
  end

  describe '#sequencing_runs' do
    it 'if the request belongs to a run' do
      plate = build(:pacbio_plate_with_wells, :pooled)
      create(:pacbio_run, plates: [plate])
      request = plate.wells.first.libraries.first.request
      expect(request.sequencing_runs).to eq([plate.run])
    end

    it 'when the request belongs to multiple runs' do
      plate1 = build(:pacbio_plate)
      plate2 = build(:pacbio_plate)
      create(:pacbio_run, plates: [plate1])
      create(:pacbio_run, plates: [plate2])
      request = create(:pacbio_request)
      library1 = create(:pacbio_library, request:)
      library2 = create(:pacbio_library, request:)
      pool = create(:pacbio_pool, libraries: [library1, library2])
      create(:pacbio_well, pools: [pool], plate: plate1)
      create(:pacbio_well, pools: [pool], plate: plate2)
      expect(request.sequencing_runs).to eq([plate1.run, plate2.run])
    end

    it 'when the request does not belong to any runs' do
      request = create(:pacbio_request)
      expect(request.sequencing_runs).to be_empty
    end
  end
end
