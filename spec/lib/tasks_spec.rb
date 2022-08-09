# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  describe 'create tags' do
    it 'creates all of the tag sets' do
      Rake::Task['tags:create:pacbio_all'].invoke
      expect(TagSet.count).to eq(6)
    end
  end

  describe 'create pacbio runs' do
    it 'creates the correct number of runs' do
      Rake::Task['tags:create:pacbio_sequel'].reenable
      Rake::Task['tags:create:pacbio_isoseq'].reenable
      Rake::Task['pacbio_data:create'].invoke
      expect(Pacbio::Run.count).to eq(6)
    end
  end

  describe 'library_types:create' do
    it 'creates the library types' do
      expect { Rake::Task['library_types:create'].invoke }.to(
        change(LibraryType, :count).by(13) &&
        output("-> Library types updated\n").to_stdout
      )
    end
  end

  describe 'data_types:create' do
    it 'creates the data types' do
      expect { Rake::Task['data_types:create'].invoke }.to(
        change(DataType, :count).by(2) &&
        output("-> Data types updated\n").to_stdout
      )
    end
  end

  describe 'ont_data:create' do
    let(:expected_plates) { 2 }
    let(:filled_wells_per_plate) { 95 }
    let(:expected_tubes) { 2 }
    let(:expected_wells) { expected_plates * filled_wells_per_plate }
    let(:expected_requests) { expected_tubes + expected_wells }

    before do
      create :library_type, :ont
      create :data_type, :ont
    end

    it 'creates plates and tubes' do
      expect { Rake::Task['ont_data:create'].invoke }.to change(Reception, :count).by(1).and change(Ont::Request, :count).by(expected_requests).and change(Sample, :count).by(expected_requests).and change(Plate, :count).by(expected_plates).and change(Well, :count).by(expected_wells).and change(Tube, :count).by(expected_tubes).and output("-> Created requests for #{expected_plates} plates and #{expected_tubes} tubes\n").to_stdout
    end
  end

  describe 'pacbio_wells:migrate_smrt_link_options' do
    # We need to set the smrt link version to v12 so it is not validated
    # generate_hifi - 'In SMRT Link' => 0, 'On Instrument' => 1, 'Do Not Generate' => 2
    let!(:well1) { create(:pacbio_well, generate_hifi_deprecated: 0, generate_hifi: nil, plate: create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: 'v12'))) }
    let!(:well2) { create(:pacbio_well, generate_hifi_deprecated: 1,  generate_hifi: nil, plate: create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: 'v12'))) }
    let!(:well3) { create(:pacbio_well, generate_hifi_deprecated: 2,  generate_hifi: nil, plate: create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: 'v12'))) }
    let!(:well4) { create(:pacbio_well, ccs_analysis_output_deprecated: 'Yes', ccs_analysis_output: nil, plate: create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: 'v12'))) }
    let!(:well5) { create(:pacbio_well, ccs_analysis_output_deprecated: 'No',  ccs_analysis_output: nil, plate: create(:pacbio_plate, run: create(:pacbio_run, smrt_link_version: 'v12'))) }

    it 'modifies the data correctly' do
      expect(Pacbio::Well.count).to eq(5)
      Rake::Task['pacbio_wells:migrate_smrt_link_options'].invoke
      [well1, well2, well3, well4, well5].collect(&:reload)
      expect(well1.generate_hifi).to eq('In SMRT Link')
      expect(well2.generate_hifi).to eq('On Instrument')
      expect(well3.generate_hifi).to eq('Do Not Generate')
      expect(well4.ccs_analysis_output).to eq('Yes')
      expect(well5.ccs_analysis_output).to eq('No')
    end
  end
end
