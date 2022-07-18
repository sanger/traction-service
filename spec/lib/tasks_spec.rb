# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

describe "Rake Tasks" do

  # If you don't reenable the task it won't run
  after(:each) do
    Rake::Task["tags:create:pacbio_all"].reenable
    Rake::Task["pacbio_data:create"].reenable
    Rake::Task["tags:create:pacbio_sequel"].reenable
    Rake::Task["tags:create:pacbio_isoseq"].reenable
  end

  describe 'create tags' do

    it 'should create all of the tag sets' do
      Rake::Task["tags:create:pacbio_all"].invoke
      expect(TagSet.count).to eq(5)
    end

  end

  describe 'create pacbio runs' do

    it 'should create the correct number of runs' do
      Rake::Task["pacbio_data:create"].invoke
      expect(Pacbio::Run.count).to eq(6)
    end
  end
end