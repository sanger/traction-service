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
      expect { Rake::Task['tags:create:pacbio_all'].invoke }.to output(
        <<~HEREDOC
          -> Creating Sequel_16_barcodes_v3 tag set and tags
          -> Tag Set successfully created
          -> Sequel_16_barcodes_v3 tags successfully created
          -> Creating Sequel_48_Microbial_Barcoded_OHA_v1tag set and tags
          -> Tag Set successfully created
          -> Sequel_48_Microbial_Barcoded_OHA_v1 tags successfully created
          -> Creating TruSeq_CD_i7_i5_D0x_8mer tag set and tags
          -> Tag Set successfully created
          -> TruSeq_CD_i7_i5_D0x_8mer tags successfully created
          -> Creating Sequel_96_Barcoded_OHA_v1 tag set and tags
          -> Tag Set successfully created
          -> Sequel_96_Barcoded_OHA_v1 tags successfully created
          -> Creating Pacbio IsoSeq tag set and tags
          -> Tag Set successfully created
          -> IsoSeq_Primers_12_Barcodes_v1 created
          -> Creating Nextera UD tag set and tags
          -> Tag Set successfully created
          -> Nextera_UD_Index_PlateA tags successfully created
          -> Creating Pacbio_96_barcode_plate_v3 tag set and tags
          -> Tag Set successfully created
          -> Pacbio_96_barcode_plate_v3 tags successfully created
        HEREDOC
      ).to_stdout
      expect(TagSet.count).to eq(7)
    end

    it 'creates all of the ont tag sets' do
      expect { Rake::Task['tags:create:ont_all'].invoke }.to output(
        <<~HEREDOC
          -> Creating SQK-NBD114.96 tag set and tags
          -> Tag Set successfully created
          -> SQK-NBD114.96 tags successfully created
        HEREDOC
      ).to_stdout
      expect(TagSet.count).to eq(1)
    end

    it 'creates all of the tag sets' do
      # We need to reenable all tag tasks because they have all already been invoked by this point
      Rake.application.in_namespace(:tags) { |namespace| namespace.tasks.each(&:reenable) }
      expect { Rake::Task['tags:create:traction_all'].invoke }.to output(
        <<~HEREDOC
          -> Creating Sequel_16_barcodes_v3 tag set and tags
          -> Tag Set successfully created
          -> Sequel_16_barcodes_v3 tags successfully created
          -> Creating Sequel_48_Microbial_Barcoded_OHA_v1tag set and tags
          -> Tag Set successfully created
          -> Sequel_48_Microbial_Barcoded_OHA_v1 tags successfully created
          -> Creating TruSeq_CD_i7_i5_D0x_8mer tag set and tags
          -> Tag Set successfully created
          -> TruSeq_CD_i7_i5_D0x_8mer tags successfully created
          -> Creating Sequel_96_Barcoded_OHA_v1 tag set and tags
          -> Tag Set successfully created
          -> Sequel_96_Barcoded_OHA_v1 tags successfully created
          -> Creating Pacbio IsoSeq tag set and tags
          -> Tag Set successfully created
          -> IsoSeq_Primers_12_Barcodes_v1 created
          -> Creating Nextera UD tag set and tags
          -> Tag Set successfully created
          -> Nextera_UD_Index_PlateA tags successfully created
          -> Creating Pacbio_96_barcode_plate_v3 tag set and tags
          -> Tag Set successfully created
          -> Pacbio_96_barcode_plate_v3 tags successfully created
          -> Creating SQK-NBD114.96 tag set and tags
          -> Tag Set successfully created
          -> SQK-NBD114.96 tags successfully created
        HEREDOC
      ).to_stdout
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
          <<~HEREDOC
            -> Creating Sequel_16_barcodes_v3 tag set and tags
            -> Tag Set successfully created
            -> Sequel_16_barcodes_v3 tags successfully created
            -> Creating Pacbio IsoSeq tag set and tags
            -> Tag Set successfully created
            -> IsoSeq_Primers_12_Barcodes_v1 created
            -> Creating pacbio plates and tubes...\b\b\b √#{' '}
            -> Creating pacbio libraries...\b\b\b √#{' '}
            -> Finding Pacbio SMRT Link versions...\b\b\b √#{' '}
            -> Creating pacbio runs:
               -> Creating runs for v11...\b\b\b √#{' '}
               -> Creating runs for v12_revio...\b\b\b √#{' '}
            -> Pacbio runs successfully created
          HEREDOC
        ).to_stdout
      expect(Pacbio::Run.count)
        .to eq(12)
    end
  end

  describe 'library_types:create' do
    it 'creates the library types' do
      expect { Rake::Task['library_types:create'].invoke }.to change(LibraryType, :count).by(15).and output(
        <<~HEREDOC
          -> Library types updated
        HEREDOC
      ).to_stdout
    end
  end

  describe 'data_types:create' do
    it 'creates the data types' do
      expect { Rake::Task['data_types:create'].invoke }.to change(DataType, :count).by(2).and output(
        <<~HEREDOC
          -> Data types updated
        HEREDOC
      ).to_stdout
    end
  end

  describe 'ont_instruments:create' do
    it 'creates the correct instrument data' do
      Rake::Task['ont_instruments:create'].reenable
      expect { Rake::Task['ont_instruments:create'].invoke }.to change(Ont::Instrument, :count).and output(
        <<~HEREDOC
          -> ONT Instruments successfully created
        HEREDOC
      ).to_stdout
    end
  end

  describe 'min_know_versions:create' do
    it 'creates the correct MinKnowVersion data' do
      expect { Rake::Task['min_know_versions:create'].invoke }.to change(Ont::MinKnowVersion, :count).and output(
        <<~HEREDOC
          -> ONT MinKnow versions successfully created
        HEREDOC
      ).to_stdout
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

  describe 'qc_assay_types:create' do
    it 'creates the correct number of qc assay types' do
      expect { Rake::Task['qc_assay_types:create'].invoke }.to change(QcAssayType, :count).by(16).and output(
        <<~HEREDOC
          -> QC Assay Types updated
        HEREDOC
      ).to_stdout
    end
  end
end
