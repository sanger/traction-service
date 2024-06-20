# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'smrt_link_versions:create' do
    it 'creates the smrt link versions and their options' do
      expect { Rake::Task['smrt_link_versions:create'].invoke }.to output(
        <<~HEREDOC
          -> Pacbio SMRT Link versions and options successfully created
        HEREDOC
      ).to_stdout

      Rails.configuration.pacbio_smrt_link_versions[:versions].each do |_key, version|
        expect(Pacbio::SmrtLinkVersion.find_by(name: version[:name])).to be_present
      end

      Rails.configuration.pacbio_smrt_link_versions[:options].each do |_key, option|
        expect(Pacbio::SmrtLinkOption.find_by(key: option[:key])).to be_present
      end

      runs = create_list(:pacbio_revio_run, 2)

      runs.each do |run|
        run.wells.each do |well|
          well.library_type = nil
          run.save(validate: false)
        end
      end

      Pacbio::SmrtLinkOption.find_by(key: 'library_type').destroy

      Rake::Task['smrt_link_versions:create'].reenable

      expect { Rake::Task['smrt_link_versions:create'].invoke }.to output(
        <<~HEREDOC
          -> Pacbio SMRT Link versions and options successfully created
        HEREDOC
      ).to_stdout

      runs.each do |run|
        run.reload
        expect(run.wells).to(be_all { |well| well.library_type == 'Standard' })
      end
    end
  end
end
