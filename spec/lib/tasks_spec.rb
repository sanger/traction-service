# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'RakeTasks' do
  describe 'create tags' do
    it 'creates all of the tag sets' do
      Rake::Task['tags:create:pacbio_all'].invoke
      expect(TagSet.count).to eq(6)
    end
  end

  describe 'create pacbio runs' do
    before do
      create :library_type, :pacbio
    end

    it 'creates the correct number of runs' do
      Rake::Task['tags:create:pacbio_sequel'].reenable
      Rake::Task['tags:create:pacbio_isoseq'].reenable
      Rake::Task['pacbio_data:create'].invoke
      expect(Pacbio::Run.count).to eq(6)
    end
  end

  describe 'library_types:create' do
    it 'creates the library types' do
      expect { Rake::Task['library_types:create'].invoke }.to(
        change(LibraryType, :count).by(13) &&
        output("-> Library types updated\n").to_stdout
      )
    end
  end

  describe 'data_types:create' do
    it 'creates the data types' do
      expect { Rake::Task['data_types:create'].invoke }.to(
        change(DataType, :count).by(2) &&
        output("-> Data types updated\n").to_stdout
      )
    end
  end

  describe 'ont_data:create' do
    let(:expected_plates) { 2 }
    let(:filled_wells_per_plate) { 95 }
    let(:expected_tubes) { 2 }
    let(:expected_wells) { expected_plates * filled_wells_per_plate }
    let(:expected_requests) { expected_tubes + expected_wells }

    before do
      create :library_type, :ont
      create :data_type, :ont
    end

    it 'creates plates and tubes' do
      expect { Rake::Task['ont_data:create'].invoke }.to change(Reception, :count).by(1).and change(Ont::Request, :count).by(expected_requests).and change(Sample, :count).by(expected_requests).and change(Plate, :count).by(expected_plates).and change(Well, :count).by(expected_wells).and change(Tube, :count).by(expected_tubes).and output("-> Created requests for #{expected_plates} plates and #{expected_tubes} tubes\n").to_stdout
    end
  end
end
