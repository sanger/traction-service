# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PacBio', pacbio: true, type: :model do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
  end

  let(:config)        { Pipelines.configure(Pipelines.load_yaml) }
  let(:pacbio_config) { config.pacbio }
  let(:revio_run)     { create(:pacbio_revio_run) }
  let(:revio_message) { Messages::Message.new(object: revio_run, configuration: pacbio_config.message) }

  # let(:sequel_run)    { create(:pacbio_sequel_run) }
  # let(:sequel_message) { Messages::Message.new(object: sequel_run, configuration: pacbio_config.message) }

  # TODO: test run with multiple plates, with multiple wells

  it 'has a lims' do
    expect(revio_message.content[:lims]).to eq(pacbio_config.lims)
    # expect(sequel_message.content[:lims]).to eq(pacbio_config.lims)
  end

  it 'has a key' do
    expect(revio_message.content[pacbio_config.key]).not_to be_empty
    # expect(sequel_message.content[pacbio_config.key]).not_to be_empty
  end

  describe 'key' do
    let(:revio_key) { revio_message.content[pacbio_config.key] }
    # let(:sequel_key) { sequel_message.content[pacbio_config.key] }

    let(:timestamp) { Time.zone.parse('Mon, 08 Apr 2019 09:15:11 UTC +00:00') }

    before do
      allow(Time).to receive(:current).and_return timestamp
    end

    it 'must have a id_pac_bio_run_lims' do
      expect(revio_key[:id_pac_bio_run_lims]).to eq(revio_run.name)
      # expect(sequel_key[:id_pac_bio_run_lims]).to eq(sequel_run.name)
    end

    it 'must have a pac_bio_run_uuid' do
      expect(revio_key[:pac_bio_run_uuid]).to eq(revio_run.uuid)
      # expect(sequel_key[:pac_bio_run_uuid]).to eq(sequel_run.uuid)
    end

    it 'must have a pac_bio_run_name' do
      expect(revio_key[:pac_bio_run_name]).to eq(revio_run.name)
      # expect(sequel_key[:pac_bio_run_name]).to eq(sequel_run.name)
    end

    it 'must have a last_updated field' do
      expect(revio_key[:last_updated]).to eq(timestamp)
      # expect(sequel_key[:last_updated]).to eq(timestamp)
    end

    context 'wells' do
      let(:plate_well) { revio_run.plates.first.wells.first }
      let(:message_well) { revio_key[:wells].first }
      # let(:sequel_message_well) { sequel_key[:wells].first }

      it 'will have the correct number' do
        expect(revio_key[:wells].length).to eq(revio_run.wells.count)
        # expect(sequel_key[:wells].length).to eq(sequel_run.wells.count)
      end

      context 'each' do
        # TODO: check each well for revio run
        it 'must have a plate number' do
          expect(message_well[:plate_number]).to eq(plate_well.plate.plate_number)
        end

        it 'must have a plate uuid lims' do
          expect(message_well[:plate_uuid_lims]).to eq(plate_well.plate.uuid)
        end

        it 'must have a well label' do
          expect(message_well[:well_label]).to eq(plate_well.position)
        end

        it 'must have a well uuid lims' do
          expect(message_well[:well_uuid_lims]).to eq(plate_well.uuid)
        end
      end

      context 'samples' do
        # TODO: check each sample for revio run
        let(:libraries) { create_list(:pacbio_library, 5, :tagged) }
        let(:library) { libraries.first }
        let(:pool) { create(:pacbio_pool, libraries:) }
        let(:request) { library.request }
        let(:message_sample) { message_well[:samples].first }
        let(:request_library) { requests.first }

        before do
          plate_well.pools = [pool]
        end

        it 'will have the correct number' do
          expect(message_well[:samples].length).to eq(5)
        end

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
          expect(message_sample[:pac_bio_library_tube_name]).to eq(library.request.sample_name)
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
    end
  end
end
