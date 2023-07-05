# frozen_string_literal: true

require 'rails_helper'

# TODO: add multiple wells to the plates
RSpec.describe 'PacBio', pacbio: true, type: :model do
  let(:timestamp) { Time.zone.parse('Mon, 08 Apr 2019 09:15:11 UTC +00:00') }
  let(:pacbio_config) { Pipelines.configure(Pipelines.load_yaml).pacbio }

  before do
    allow(Time).to receive(:current).and_return timestamp

    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
  end

  shared_examples 'check the high level content' do
    it 'has a lims' do
      expect(message.content[:lims]).to eq(pacbio_config.lims)
    end

    it 'has a key' do
      expect(message.content[pacbio_config.key]).not_to be_empty
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
    it 'will have the correct number' do
      expect(key[:wells].length).to eq(run.wells.count)
    end
  end

  shared_examples 'check each well' do
    it 'must have the' do
      expect(message_well[:well_label]).to eq(well.position)
    end

    it 'must have a plate number' do
      expect(message_well[:plate_number]).to eq(well.plate.plate_number)
    end

    it 'must have a well label' do
      expect(message_well[:well_label]).to eq(well.position)
    end

    it 'must have a well uuid lims' do
      expect(message_well[:well_uuid_lims]).to eq(well.uuid)
    end
  end

  shared_examples 'check the plate samples' do
    it 'will have the correct number' do
      expect(message_well[:samples].length).to eq(5)
    end
  end

  shared_examples 'check each sample' do
    let(:library) { well.libraries.first }
    let(:request) { library.request }

    it 'must have a cost code' do
      expect(message_sample[:cost_code]).to eq(request.cost_code)
    end

    it 'must have a library tube id' do
      expect(message_sample[:pac_bio_library_tube_id_lims]).to eq(library.id)
    end

    it 'must have a well uuid lims' do
      expect(message_sample[:pac_bio_library_tube_uuid]).to eq(library.uuid)
    end

    it 'must have a sample name' do
      expect(message_sample[:pac_bio_library_tube_name]).to eq(request.sample_name)
    end

    it 'can have a pool barcode' do
      expect(message_sample[:pac_bio_library_tube_barcode]).to eq(library.pool.tube.barcode)
    end

    it 'must have a sample_uuid' do
      expect(message_sample[:sample_uuid]).to eq(request.sample.external_id)
    end

    it 'must have a study_uuid' do
      expect(message_sample[:study_uuid]).to eq(request.external_study_id)
    end

    it 'can have a tag sequence' do
      expect(message_sample[:tag_sequence]).to eq(library.tag.oligo)
    end

    it 'can have a tag group id' do
      expect(message_sample[:tag_set_id_lims]).to eq(library.tag.tag_set.id)
    end

    it 'can have a tag identifier' do
      expect(message_sample[:tag_identifier]).to eq(library.tag.group_id)
    end

    it 'can have a tag set name' do
      expect(message_sample[:tag_set_name]).to eq(library.tag.tag_set.name)
    end

    it 'can have a pipeline id' do
      expect(message_sample[:pipeline_id_lims]).to eq(request.library_type)
    end
  end

  context 'when the run is Sequel IIe' do
    let(:run)            { create(:pacbio_sequel_run) }
    let(:libraries)      { create_list(:pacbio_library, 5, :tagged) }
    let(:pool)           { create(:pacbio_pool, libraries:) }

    let(:message)        { Messages::Message.new(object: run, configuration: pacbio_config.message) }
    let(:key)            { message.content[pacbio_config.key] }

    let(:message_well)   { key[:wells][0] }
    let(:message_sample) { message_well[:samples][0] }
    let(:well)           { run.plates[0].wells[0] }

    before do
      well.pools = [pool]
    end

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
    let(:pool)           { create(:pacbio_pool, libraries:) }

    let(:message)        { Messages::Message.new(object: run, configuration: pacbio_config.message) }
    let(:key)            { message.content[pacbio_config.key] }

    let(:message_well)   { key[:wells][0] }
    let(:message_sample) { message_well[:samples][0] }
    let(:well)           { run.plates[0].wells[0] }

    before do
      well.pools = [pool]
    end

    it_behaves_like 'check the high level content'
    it_behaves_like 'check the keys'
    it_behaves_like 'check the plate wells'
    it_behaves_like 'check each well'
    it_behaves_like 'check the plate samples'
    it_behaves_like 'check each sample'
  end
end
