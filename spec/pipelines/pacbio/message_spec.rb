# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PacBio', :pacbio, type: :model do
  let(:timestamp) { Time.zone.parse('Mon, 08 Apr 2019 09:15:11 UTC +00:00') }
  let(:configuration) { Pipelines.configure(Pipelines.load_yaml) }
  let(:message_configuration) { configuration.pacbio.message }

  before do
    allow(Time).to receive(:current).and_return timestamp

    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
  end

  shared_examples 'check the high level content' do
    it 'has a lims' do
      expect(message.content[:lims]).to eq(message_configuration.lims)
    end

    it 'has a key' do
      expect(message.content[message_configuration.key]).not_to be_empty
    end
  end

  shared_examples 'check the keys' do
    it 'must have a id_pac_bio_run_lims' do
      expect(key[:id_pac_bio_run_lims]).to eq(run.name)
    end

    it 'must have a pac_bio_run_uuid' do
      expect(key[:pac_bio_run_uuid]).to eq(run.uuid)
    end

    it 'must have a pac_bio_run_name' do
      expect(key[:pac_bio_run_name]).to eq(run.name)
    end

    it 'must have a last_updated field' do
      expect(key[:last_updated]).to eq(timestamp)
    end
  end

  shared_examples 'check the plate wells' do
    it 'has the correct number of wells for each plate' do
      expect(key[:wells].length).to eq(run.wells.count)
    end
  end

  shared_examples 'check each well' do
    it 'must have the message well information' do
      message_wells.each_with_index do |message_well, index|
        expect(message_well[:plate_number]).to eq(wells[index].plate.plate_number)
        expect(message_well[:plate_uuid_lims]).to eq(wells[index].plate.uuid)
        expect(message_well[:well_label]).to eq(wells[index].position)
        expect(message_well[:well_uuid_lims]).to eq(wells[index].uuid)
      end
    end
  end

  shared_examples 'check the plate samples' do
    it 'has the correct number of samples for each well' do
      message_wells.each do |message_well|
        message_samples = message_well[:samples]
        expect(message_samples.length).to eq(5)
      end
    end
  end

  shared_examples 'check each sample' do
    it 'must have the message sample information' do
      message_wells.each_with_index do |message_well, well_index|
        well = wells[well_index]

        message_samples = message_well[:samples]

        message_samples.each_with_index do |message_sample, sample_index|
          aliquot = well.all_used_aliquots[sample_index]
          request = aliquot.source

          expect(message_sample[:cost_code]).to eq(request.cost_code)
          expect(message_sample[:pac_bio_library_tube_id_lims]).to eq(aliquot.used_by.id)
          expect(message_sample[:pac_bio_library_tube_uuid]).to eq('')
          expect(message_sample[:pac_bio_library_tube_name]).to eq(request.sample_name)
          expect(message_sample[:pac_bio_library_tube_barcode]).to eq(aliquot.used_by.tube.barcode)
          expect(message_sample[:sample_uuid]).to eq(request.sample.external_id)
          expect(message_sample[:study_uuid]).to eq(request.external_study_id)
          expect(message_sample[:tag_sequence]).to eq(aliquot.tag.oligo)
          expect(message_sample[:tag_set_id_lims]).to eq(aliquot.tag.tag_set.id)
          expect(message_sample[:tag_identifier]).to eq(aliquot.tag.group_id)
          expect(message_sample[:tag_set_name]).to eq(aliquot.tag.tag_set.name)
          expect(message_sample[:pipeline_id_lims]).to eq(request.library_type)
        end
      end
    end
  end

  context 'when the run is Sequel IIe' do
    let(:run)            { create(:pacbio_sequel_run) }
    let(:libraries)      { create_list(:pacbio_library, 5, :tagged) }
    let(:pool)           { create(:pacbio_pool) }

    let(:message)        { Message::Message.new(object: run, configuration: message_configuration) }
    let(:key)            { message.content[message_configuration.key] }

    let(:message_wells)  { key[:wells] }
    let(:wells)          { run.plates[0].wells }

    it_behaves_like 'check the high level content'
    it_behaves_like 'check the keys'
    it_behaves_like 'check the plate wells'
    it_behaves_like 'check each well'
    it_behaves_like 'check the plate samples'
    it_behaves_like 'check each sample'
  end

  context 'when the run is Revio' do
    let(:run)            { create(:pacbio_revio_run) }
    let(:libraries)      { create_list(:pacbio_library, 5, :tagged) }
    let(:pool)           { create(:pacbio_pool) }

    let(:message)        { Message::Message.new(object: run, configuration: message_configuration) }
    let(:key)            { message.content[message_configuration.key] }

    let(:message_wells)  { key[:wells] }
    let(:wells)          { [run.plates[0].wells, run.plates[1].wells].flatten }

    it_behaves_like 'check the high level content'
    it_behaves_like 'check the keys'
    it_behaves_like 'check the plate wells'
    it_behaves_like 'check each well'
    it_behaves_like 'check the plate samples'
    it_behaves_like 'check each sample'
  end
end
