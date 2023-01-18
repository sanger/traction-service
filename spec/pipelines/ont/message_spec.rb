# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Ont', ont: true, type: :model do
  let(:config)            { Pipelines.configure(Pipelines.load_yaml) }
  let(:pipeline_config)   { config.ont.message }
  let(:run)               { create(:ont_run, flowcell_count: 2) }
  let(:message) do
    Messages::Message.new(object: run, configuration: pipeline_config.message)
  end

  it 'has a lims' do
    expect(message.content[:lims]).to eq(pipeline_config.lims)
  end

  it 'has a key' do
    expect(message.content[pipeline_config.key]).not_to be_empty
  end

  describe 'key' do
    let(:key) { message.content[pipeline_config.key] }

    let(:timestamp) { Time.zone.parse('Mon, 08 Apr 2019 09:15:11 UTC +00:00') }

    before do
      allow(Time).to receive(:current).and_return timestamp
    end

    it 'must have a last_updated field' do
      expect(key[:last_updated]).to eq(timestamp)
    end

    it 'must have an experiment_name' do
      expect(key[:experiment_name]).to eq(run.experiment_name)
    end

    it 'must have an instrument_name' do
      expect(key[:instrument_name]).to eq(run.instrument.name)
    end

    it 'must have a run_uuid' do
      expect(key[:run_uuid]).to eq(run.uuid)
    end

    context 'flowcells' do
      let(:flowcell) { run.flowcells.first }
      let(:message_flowcell) { key[:flowcells].first }

      it 'will have the correct number' do
        expect(key[:flowcells].length).to eq(run.flowcells.count)
      end

      context 'each' do
        it 'must have an id_flowcell_lims' do
          expect(message_flowcell[:id_flowcell_lims]).to eq(flowcell.uuid)
        end

        it 'must have an instrument_slot' do
          expect(message_flowcell[:instrument_slot]).to eq(flowcell.position)
        end

        it 'must have a flowcell_id' do
          expect(message_flowcell[:flowcell_id]).to eq(flowcell.flowcell_id)
        end
      end

      context 'samples' do
        let(:libraries) { flowcell.libraries }

        it 'will have the correct number' do
          expect(message_flowcell[:samples].length).to eq(libraries.length)
        end

        context 'each' do
          let(:message_sample) { message_flowcell[:samples].first }
          let(:library) { libraries.first }

          it 'must have a sample_uuid' do
            expect(message_sample[:sample_uuid]).to eq(library.request.sample.external_id)
          end

          it 'must have a study_uuid' do
            expect(message_sample[:study_uuid]).to eq(library.request.external_study_id)
          end

          it 'must have a pipeline_id_lims' do
            expect(message_sample[:pipeline_id_lims]).to eq(library.request.library_type.name)
          end

          it 'must have a requested_data_type' do
            expect(message_sample[:requested_data_type]).to eq(library.request.data_type.name)
          end

          it 'must have a library_tube_uuid' do
            expect(message_sample[:library_tube_uuid]).to eq(library.pool.uuid)
          end

          it 'must have a library_tube_barcode' do
            expect(message_sample[:library_tube_barcode]).to eq(library.pool.tube.barcode)
          end

          it 'must have a tag_identifier' do
            expect(message_sample[:tag_identifier]).to eq(library.tag.group_id)
          end

          it 'must have a tag_sequence' do
            expect(message_sample[:tag_sequence]).to eq(library.tag.oligo)
          end

          it 'must have a tag_set_id_lims' do
            expect(message_sample[:tag_set_id_lims]).to eq(library.tag.tag_set.id)
          end

          it 'must have a tag_set_id_name' do
            expect(message_sample[:tag_set_name]).to eq(library.tag.tag_set.name)
          end

          it 'passes tag2_identifier as nil' do
            expect(message_sample[:tag2_identifier]).to be_nil
          end

          it 'passes tag2_sequence as nil' do
            expect(message_sample[:tag2_sequence]).to be_nil
          end

          it 'passes tag2_set_id_lims as nil' do
            expect(message_sample[:tag2_set_id_lims]).to be_nil
          end

          it 'passes tag2_set_name as nil' do
            expect(message_sample[:tag2_set_name]).to be_nil
          end
        end
      end
    end
  end
end
