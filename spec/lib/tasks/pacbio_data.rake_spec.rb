# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v10') || create(:pacbio_smrt_link_version, name: 'v10', default: true)
    Pacbio::SmrtLinkVersion.find_by(name: 'v11') || create(:pacbio_smrt_link_version, name: 'v11')
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio') || create(:pacbio_smrt_link_version, name: 'v12_revio')
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
end
