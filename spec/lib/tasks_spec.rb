# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  describe 'create tags' do
    it 'creates all of the tag sets' do
      Rake::Task['tags:create:pacbio_all'].invoke
      expect(TagSet.count).to eq(5)
    end
  end

  describe 'create pacbio runs' do
    it 'creates the correct number of runs' do
      Rake::Task['tags:create:pacbio_sequel'].reenable
      Rake::Task['tags:create:pacbio_isoseq'].reenable
      Rake::Task['pacbio_data:create'].invoke
      expect(Pacbio::Run.count).to eq(6)
    end
  end
end
