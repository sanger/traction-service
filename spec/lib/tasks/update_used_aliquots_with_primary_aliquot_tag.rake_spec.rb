# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'used_aliquots:update_tags' do
    it 'updates used aliquots with primary aliquot tag' do
      libraries = create_list(:pacbio_library, 5)
      tag = create(:tag)
      libraries.each do |library|
        library.used_aliquots.first.update!(tag:)
      end

      expect { Rake::Task['used_aliquots:update_tags'].invoke }.to output(
        "-> #{libraries.count} instances of libraries updated.\n"
      ).to_stdout

      libraries.each do |library|
        library.reload
        expect(library.used_aliquots.first.tag).to eq(library.tag)
      end
    end
  end
end
