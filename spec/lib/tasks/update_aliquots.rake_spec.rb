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

  describe 'update_aliquots:update_uuid' do
    define_negated_matcher :not_change, :change

    it 'assigns a random UUID to all aliquots that currently lack one.' do
      aliquots_with_empty_uuid = create_list(:aliquot, 5, used_by: create(:pacbio_pool), uuid: nil)
      aliquots_with_uuid = create_list(:aliquot, 5, used_by: create(:pacbio_pool))

      # Get uuids to check they are not affected
      uuids = aliquots_with_uuid.map(&:uuid)

      # We shouldnt change the amount of aliquots
      expect { Rake::Task['update_aliquots:update_uuid'].invoke }.to not_change(Aliquot, :count).and output(
        <<~HEREDOC
          -> Updating aliquots with UUID
        HEREDOC
      ).to_stdout

      # Aliquots without uuids should have a uuid set
      aliquots_with_empty_uuid.each do |aliquot|
        aliquot.reload
        expect(aliquot.uuid).not_to be_nil
      end

      # Other aliquots should not be affected
      aliquots_with_uuid.each do |aliquot|
        aliquot.reload
        expect(uuids).to include aliquot.uuid
      end
    end
  end
end
