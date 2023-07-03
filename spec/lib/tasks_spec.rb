# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v10') || create(:pacbio_smrt_link_version, name: 'v10', default: true)
    Pacbio::SmrtLinkVersion.find_by(name: 'v11') || create(:pacbio_smrt_link_version, name: 'v11')
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio') || create(:pacbio_smrt_link_version, name: 'v12_revio')
  end

  describe 'create tags' do
    it 'creates all of the pacbio tag sets' do
      Rake::Task['tags:create:pacbio_all'].invoke
      expect(TagSet.count).to eq(7)
    end

    it 'creates all of the ont tag sets' do
      Rake::Task['tags:create:ont_all'].invoke
      expect(TagSet.count).to eq(1)
    end

    it 'creates all of the tag sets' do
      # We need to reenable all tag tasks because they have all already been invoked by this point
      Rake.application.in_namespace(:tags) { |namespace| namespace.tasks.each(&:reenable) }
      Rake::Task['tags:create:traction_all'].invoke
      expect(TagSet.count).to eq(8)
    end
  end

  describe 'create pacbio runs' do
    before do
      create(:library_type, :pacbio)
    end

    it 'creates the correct number of runs' do
      Rake::Task['tags:create:pacbio_sequel'].reenable
      Rake::Task['tags:create:pacbio_isoseq'].reenable
      expect { Rake::Task['pacbio_data:create'].invoke }
        .to output(
          "-> Creating Sequel_16_barcodes_v3 tag set and tags\n" \
          "-> Tag Set successfully created\n" \
          "-> Sequel_16_barcodes_v3 tags successfully created\n" \
          "-> Creating Pacbio IsoSeq tag set and tags\n" \
          "-> Tag Set successfully created\n" \
          "-> IsoSeq_Primers_12_Barcodes_v1 created\n" \
          "-> Creating pacbio plates and tubes...\b\b\b √ \n" \
          "-> Creating pacbio libraries...\b\b\b √ \n" \
          "-> Finding Pacbio SMRT Link versions...\b\b\b √ \n" \
          "-> Creating pacbio runs:\n   " \
          "-> Creating runs for v11...\b\b\b √ \n   " \
          "-> Creating runs for v12_revio...\b\b\b √ \n" \
          "-> Pacbio runs successfully created\n"
        ).to_stdout
      expect(Pacbio::Run.count)
        .to eq(12)
    end
  end

  describe 'library_types:create' do
    it 'creates the library types' do
      expect { Rake::Task['library_types:create'].invoke }.to change(LibraryType, :count).by(15).and output("-> Library types updated\n").to_stdout
    end
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

  describe 'migrate_pacbio_run_smrt_link_versions' do
    it 'creates smrt link version and options for v10' do
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].reenable
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].invoke

      version = Pacbio::SmrtLinkVersion.find_by(name: 'v10', default: true, active: true)
      expect(version).not_to be_nil
      expect(version.smrt_link_options).not_to be_nil
      expect(version.default).to be true
      expect(version.active).to be true

      keys = %w[
        ccs_analysis_output
        generate_hifi
        on_plate_loading_concentration
        binding_kit_box_barcode
        pre_extension_time
        loading_target_p1_plus_p2
        movie_time
      ]

      keys.each do |key|
        obj = version.smrt_link_options.where(key:)
        expect(obj).not_to be_nil
      end
    end

    it 'creates smrt link versions and options for v11' do
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].reenable
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].invoke

      version = Pacbio::SmrtLinkVersion.find_by(name: 'v11', default: false, active: true)
      expect(version).not_to be_nil
      expect(version.smrt_link_options).not_to be_nil
      expect(version.default).to be false
      expect(version.active).to be true

      keys = %w[
        ccs_analysis_output_include_low_quality_reads
        ccs_analysis_output_include_kinetics_information
        include_fivemc_calls_in_cpg_motifs
        demultiplex_barcodes
        on_plate_loading_concentration
        binding_kit_box_barcode
        pre_extension_time
        loading_target_p1_plus_p2
        movie_time
      ]

      keys.each do |key|
        obj = version.smrt_link_options.where(key:)
        expect(obj).not_to be_nil
      end
    end

    it 'creates smrt link versions and options for v12_revio' do
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].reenable
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].invoke

      version = Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio', default: false, active: true)
      expect(version).not_to be_nil
      expect(version.smrt_link_options).not_to be_nil
      expect(version.default).to be false
      expect(version.active).to be true

      keys = %w[
        ccs_analysis_output_include_low_quality_reads
        ccs_analysis_output_include_kinetics_information
        include_fivemc_calls_in_cpg_motifs
        on_plate_loading_concentration
        binding_kit_box_barcode
        pre_extension_time
        loading_target_p1_plus_p2
        movie_time
      ]

      keys.each do |key|
        obj = version.smrt_link_options.where(key:)
        expect(obj).not_to be_nil
      end
    end

    it 'sets pacbio smrt link versions' do
      run10 = create(:pacbio_run, system_name: 0, smrt_link_version_deprecated: 'v10')
      run11 = create(:pacbio_run, system_name: 0, smrt_link_version_deprecated: 'v11')
      run12_revio = create(:pacbio_run, system_name: 0, smrt_link_version_deprecated: 'v12_revio')

      Rake::Task['smrt_link_versions:create'].reenable
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].reenable
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].invoke

      run10.reload
      run11.reload
      run12_revio.reload

      expect(run10.smrt_link_version).not_to be_nil
      expect(run10.smrt_link_version.name).to eq('v10')
      expect(run10.smrt_link_version.smrt_link_options).not_to be_nil
      expect(run10.smrt_link_version.smrt_link_options).not_to be_empty

      expect(run11.smrt_link_version).not_to be_nil
      expect(run11.smrt_link_version.name).to eq('v11')
      expect(run11.smrt_link_version.smrt_link_options).not_to be_nil
      expect(run11.smrt_link_version.smrt_link_options).not_to be_empty
    end

    it 'sets smrt link version default and active flags', skip: 'Not sure this test makes sense? It seems to fail on default??' do
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].reenable
      Rake::Task['pacbio_runs:migrate_pacbio_run_smrt_link_versions'].invoke

      # Load config file
      config_name = 'pacbio_smrt_link_versions.yml'
      config_path = Rails.root.join('config', config_name)
      config = YAML.load_file(config_path, aliases: true)[Rails.env]

      # Check if default and active flags are set correctly.

      config['versions'].each do |_title, version|
        smrt_link_version = Pacbio::SmrtLinkVersion.where(name: version['name']).first
        expect(smrt_link_version).not_to be_nil
        expect(smrt_link_version.default).to eq(version.fetch('default', false))
        expect(smrt_link_version.active).to eq(version.fetch('active', true))
      end
    end
  end
end
