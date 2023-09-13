# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v10') || create(:pacbio_smrt_link_version, name: 'v10', default: true)
    Pacbio::SmrtLinkVersion.find_by(name: 'v11') || create(:pacbio_smrt_link_version, name: 'v11')
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio') || create(:pacbio_smrt_link_version, name: 'v12_revio')
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
          "-> Creating SQK-RBK114.96 tag set and tags\n" \
          "-> Tag Set successfully created\n" \
          "-> SQK-RBK114.96 tags successfully created\n" \
          "-> Created #{expected_single_plexed_pools} single plexed pools\n" \
          "-> Created #{expected_multi_plexed_pools} multiplexed pools\n" \
          "-> ONT Instruments successfully created\n" \
          "-> ONT MinKnow versions successfully created\n" \
          "-> Created #{expected_runs} sequencing runs\n" \
          "-> Created #{expected_flowcells} flowcells\n"
        ).to_stdout
    end
  end
end
