# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  # Create a default SMRTLink version to be used by factories
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v13_sequel_iie') || create(:pacbio_smrt_link_version, name: 'v13_sequel_iie', default: true)
  end

  describe 'volume_tracking:clear_well_aliquot_volume' do
    define_negated_matcher :not_change, :change

    it 'sets the volume and concentration of all well aliquots to 0' do
      # Create some other aliquots to check they are not affected
      pool_aliquots = create_list(:aliquot, 5, used_by: create(:pacbio_pool), volume: 10, concentration: 10)
      create_list(:aliquot, 5, used_by: create(:pacbio_library), volume: 10, concentration: 10)

      # Data we want to change
      well_aliquots = create_list(:aliquot, 10, used_by: create(:pacbio_well), volume: 10, concentration: 10)

      # We shouldnt change the amount of aliquots
      expect { Rake::Task['volume_tracking:clear_well_aliquot_volume'].invoke }.to not_change(Aliquot, :count).and output(
        <<~HEREDOC
          -> Clearing volume of all well aliquots
        HEREDOC
      ).to_stdout

      # Well aliquots should have their volume and concentration set to 0
      well_aliquots.each do |aliquot|
        aliquot.reload
        expect(aliquot.volume).to eq 0
        expect(aliquot.concentration).to eq 0
      end

      # Other aliquots should not be affected
      pool_aliquots.each do |aliquot|
        aliquot.reload
        expect(aliquot.volume).to eq 10
        expect(aliquot.concentration).to eq 10
      end
    end
  end
end
