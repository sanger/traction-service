# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v10') || create(:pacbio_smrt_link_version, name: 'v10')
    Pacbio::SmrtLinkVersion.find_by(name: 'v11') || create(:pacbio_smrt_link_version, name: 'v11')
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio') || create(:pacbio_smrt_link_version, name: 'v12_revio')
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_sequel_iie') || create(:pacbio_smrt_link_version, name: 'v12_sequel_iie', default: true)
    Pacbio::SmrtLinkVersion.find_by(name: 'v13_revio') || create(:pacbio_smrt_link_version, name: 'v13_revio')
    Pacbio::SmrtLinkVersion.find_by(name: 'v13_sequel_iie') || create(:pacbio_smrt_link_version, name: 'v13_sequel_iie')
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
            -> Creating pacbio libraries and pools...\b\b\b √#{' '}
            -> Finding Pacbio SMRT Link versions...\b\b\b √#{' '}
            -> Creating pacbio runs:
               -> Creating runs for v11...\b\b\b √#{' '}
               -> Creating runs for v12_revio...\b\b\b √#{' '}
               -> Creating runs for v12_sequel_iie...\b\b\b √#{' '}
               -> Creating runs for v13_revio...\b\b\b √#{' '}
               -> Creating runs for v13_sequel_iie...\b\b\b √#{' '}
            -> Pacbio runs successfully created
          HEREDOC
        ).to_stdout
      expect(Pacbio::Run.count).to eq(14)
    end
  end
end
