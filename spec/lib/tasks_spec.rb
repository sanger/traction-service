# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v10') || create(:pacbio_smrt_link_version, name: 'v10', default: true)
    Pacbio::SmrtLinkVersion.find_by(name: 'v11') || create(:pacbio_smrt_link_version, name: 'v11')
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio') || create(:pacbio_smrt_link_version, name: 'v12_revio')
  end

  describe 'data_types:create' do
    it 'creates the data types' do
      expect { Rake::Task['data_types:create'].invoke }.to change(DataType, :count).by(2).and output("-> Data types updated\n").to_stdout
    end
  end

  describe 'ont_instruments:create' do
    it 'creates the correct instrument data' do
      Rake::Task['ont_instruments:create'].reenable
      expect { Rake::Task['ont_instruments:create'].invoke }.to change(Ont::Instrument, :count).and output("-> ONT Instruments successfully created\n").to_stdout
    end
  end

  describe 'min_know_versions:create' do
    it 'creates the correct MinKnowVersion data' do
      expect { Rake::Task['min_know_versions:create'].invoke }.to change(Ont::MinKnowVersion, :count).and output("-> ONT MinKnow versions successfully created\n").to_stdout
    end
  end

  describe 'ont_data:create' do
    let(:expected_plates) { 2 }
    let(:filled_wells_per_plate) { 95 }
    let(:expected_tubes) { 2 }
    let(:expected_single_plexed_pools) { 5 }
    let(:expected_multi_plexed_pools) { 10 }
    let(:expected_tag_sets) { 1 }
    let(:expected_wells) { expected_plates * filled_wells_per_plate }
    let(:expected_requests) { expected_tubes + expected_wells }
    let(:expected_runs) { 6 }
    let(:expected_flowcells) { 12 }

    before do
      create(:library_type, :ont)
      create(:data_type, :ont)
      # We need to reenable all tag tasks because they have all already been invoked by this point
      # And ont tags can be called from ont_data:create
      Rake.application.in_namespace(:tags) { |namespace| namespace.tasks.each(&:reenable) }
      Rake::Task['ont_instruments:create'].reenable
      Rake::Task['min_know_versions:create'].reenable
    end

    it 'creates plates and tubes' do
      # Each pool also has a tube so we create tubes then we create pools with tubes (17)
      expect { Rake::Task['ont_data:create'].invoke }
        .to change(Reception, :count).by(1)
        .and change(Sample, :count).by(expected_requests)
        .and change(Plate, :count).by(expected_plates)
        .and change(Well, :count).by(expected_wells)
        .and change(Tube, :count).by(expected_tubes + expected_single_plexed_pools + expected_multi_plexed_pools)
        .and change(Ont::Request, :count).by(expected_requests)
        .and change(Ont::Pool, :count).by(expected_single_plexed_pools + expected_multi_plexed_pools)
        .and change(Ont::Run, :count).by(expected_runs)
        .and change(Ont::Flowcell, :count).by(expected_flowcells)
        .and change(Ont::Library, :count)
        .and change(Ont::Instrument, :count)
        .and change(Ont::MinKnowVersion, :count)
        .and output(
          "-> Created requests for #{expected_plates} plates and #{expected_tubes} tubes\n" \
          "-> Creating SQK-NBD114.96 tag set and tags\n" \
          "-> Tag Set successfully created\n" \
          "-> SQK-NBD114.96 tags successfully created\n" \
          "-> Created #{expected_single_plexed_pools} single plexed pools\n" \
          "-> Created #{expected_multi_plexed_pools} multiplexed pools\n" \
          "-> ONT Instruments successfully created\n" \
          "-> ONT MinKnow versions successfully created\n" \
          "-> Created #{expected_runs} sequencing runs\n" \
          "-> Created #{expected_flowcells} flowcells\n"
        ).to_stdout
    end
  end

  describe 'pacbio_wells:migrate_smrt_link_options' do
    # We need to set the smrt link version to v12 so it is not validated
    # generate_hifi - 'In SMRT Link' => 0, 'On Instrument' => 1, 'Do Not Generate' => 2
    let!(:version12) { create(:pacbio_smrt_link_version, name: 'v12') }
    let!(:run) { create(:pacbio_run, system_name: 0, smrt_link_version: version12) }
    let!(:plate) { create(:pacbio_plate, run:) }
    let!(:well1) { create(:pacbio_well, generate_hifi_deprecated: 0, generate_hifi: nil, plate:) }
    let!(:well2) { create(:pacbio_well, generate_hifi_deprecated: 1,  generate_hifi: nil, plate:) }
    let!(:well3) { create(:pacbio_well, generate_hifi_deprecated: 2,  generate_hifi: nil, plate:) }
    let!(:well4) { create(:pacbio_well, ccs_analysis_output_deprecated: 'Yes', ccs_analysis_output: nil, plate:) }
    let!(:well5) { create(:pacbio_well, ccs_analysis_output_deprecated: 'No',  ccs_analysis_output: nil, plate:) }

    it 'modifies the data correctly' do
      expect(Pacbio::Well.count).to eq(6) # create(:pacbio_plate) also creates a well
      Rake::Task['pacbio_wells:migrate_smrt_link_options'].invoke
      [well1, well2, well3, well4, well5].collect(&:reload)
      expect(well1.generate_hifi).to eq('In SMRT Link')
      expect(well2.generate_hifi).to eq('On Instrument')
      expect(well3.generate_hifi).to eq('Do Not Generate')
      expect(well4.ccs_analysis_output).to eq('Yes')
      expect(well5.ccs_analysis_output).to eq('No')
    end
  end

  describe 'qc_assay_types:create' do
    it 'creates the correct number of qc assay types' do
      expect { Rake::Task['qc_assay_types:create'].invoke }.to change(QcAssayType, :count).by(10).and output("-> QC Assay Types updated\n").to_stdout
    end
  end

  describe 'deprecate_existing_pacbio_smrt_link_columns' do
    let!(:version) { create(:pacbio_smrt_link_version, name: 'v12') }

    it 'migrates data from deprecated columns to store' do
      well = build(
        :pacbio_well,
        on_plate_loading_concentration_deprecated: 1,
        on_plate_loading_concentration: nil,
        binding_kit_box_barcode_deprecated: '2',
        binding_kit_box_barcode: nil,
        pre_extension_time_deprecated: 3,
        pre_extension_time: nil,
        loading_target_p1_plus_p2_deprecated: 0.4,
        loading_target_p1_plus_p2: nil,
        movie_time_deprecated: 5,
        movie_time: nil,
        plate: create(:pacbio_plate, run: create(:pacbio_run, system_name: 0, smrt_link_version: version))
      )
      # Skip validations in the following to be able set nil for options as
      # entry condition.
      well.save!(validate: false)

      # Reenabling the task makes it possible to invoke again.
      # Invoke the data migration task for smrt_link options.
      Rake::Task['pacbio_wells:migrate_smrt_link_options'].reenable
      Rake::Task['pacbio_wells:migrate_smrt_link_options'].invoke

      # Reload the attributes of the record from the database.
      # We want to see what was saved by the task.
      well.reload

      expect(well.on_plate_loading_concentration).to eq(1)
      expect(well.binding_kit_box_barcode).to eq('2')
      expect(well.pre_extension_time).to eq(3)
      expect(well.loading_target_p1_plus_p2).to eq(0.4)
      expect(well.movie_time).to eq(5)
    end
  end
end
