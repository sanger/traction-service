# frozen_string_literal: true

require 'rails_helper'
require './spec/support/read_only'

RSpec.describe 'Ont', :skip, ont: true, type: :model do
  let(:config)            { Pipelines.configure(Pipelines.load_yaml) }
  let(:pipeline_config)   { config.ont.message }
  let(:run)               { create(:ont_run_with_flowcells) }
  let(:message) do
    Messages::Message.new(object: run, configuration: pipeline_config.message)
  end

  before do
    set_read_only([Ont::Flowcell, Ont::Library, Ont::Request, Ont::Run], false)
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
      expect(key[:instrument_name]).to eq('GXB02004')
    end

    it 'passes pipeline_id_lims as nil' do
      expect(key[:pipeline_id_lims]).to be_nil
    end

    it 'passes requested_data_type as nil' do
      expect(key[:requested_data_type]).to be_nil
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
      end

      context 'samples' do
        let(:requests) { flowcell.requests }

        it 'will have the correct number' do
          expect(message_flowcell[:samples].length).to eq(requests.length)
        end

        context 'each' do
          # We are in the process of re-implementing the ONT pipeline
          # to follow the same patterns as PacBio. However during this
          # time flowcell messages will be broken. I'm leaving the tests
          # in place, as we expect the same eventual behaviour.
          before { skip('Awaiting re-implementation of other ONT work') }

          let(:message_sample) { message_flowcell[:samples].first }
          let(:request) { requests.first }

          it 'must have a sample_uuid' do
            expect(message_sample[:sample_uuid]).to eq(request.external_id)
          end

          it 'must have a study_uuid' do
            expect(message_sample[:study_uuid]).to be_present
          end

          it 'must have a tag_identifier' do
            expect(message_sample[:tag_identifier]).to eq(request.tags.first.group_id)
          end

          it 'must have a tag_sequence' do
            expect(message_sample[:tag_sequence]).to eq(request.tags.first.oligo)
          end

          it 'must have a tag_set_id_lims' do
            expect(message_sample[:tag_set_id_lims]).to eq(request.tags.first.tag_set.id)
          end

          it 'must have a tag_set_id_lims' do
            expect(message_sample[:tag_set_name]).to eq(request.tags.first.tag_set.name)
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
