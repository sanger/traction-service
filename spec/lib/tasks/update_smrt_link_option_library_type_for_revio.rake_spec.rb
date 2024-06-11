# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'pacbio_run:update_smrt_link_option_library_type_for_revio' do
    it 'updates the smrt link option library types' do
      create(:pacbio_smrt_link_version, name: 'v13_revio', default: true)
      runs = create_list(:pacbio_revio_run, 2)
      runs.each { |run| run.update_smrt_link_options(library_type: nil) }
      expect { Rake::Task['pacbio_run:update_smrt_link_option_library_type_for_revio'].invoke }.to output(
        <<~HEREDOC
          -> 6 instances of smrt_link_options library_type updated.
        HEREDOC
      ).to_stdout
      runs.each do |run|
        run.reload
        expect(run.wells).to(be_all { |well| well.library_type == 'Standard' })
      end
    end
  end
end
