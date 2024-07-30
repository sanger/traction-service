# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v13_sequel_iie') || create(:pacbio_smrt_link_version, name: 'v13_sequel_iie', default: true)
  end

  describe 'used_aliquots:update_tags' do
    it 'updates used aliquots with primary aliquot tag' do
      tag = create(:tag)
      wells = create_list(:pacbio_well, 5, library_count: 1, pool_count: 0)
      create(:pacbio_well, library_count: 1, pool_count: 0)

      expect(Messages).to receive(:publish).exactly(wells.count).times

      wells.each do |well|
        well.libraries.first.used_aliquots.first.update!(tag:)
      end

      expect { Rake::Task['used_aliquots:update_tags'].invoke }.to output(
        "-> #{wells.count} instances of libraries updated.\n"
      ).to_stdout

      wells.each do |well|
        well.reload
        library = well.libraries.first
        expect(library.used_aliquots.first.tag).to eq(library.tag)
      end
    end
  end
end
