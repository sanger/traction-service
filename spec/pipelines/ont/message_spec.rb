require "rails_helper"

RSpec.describe 'Ont', type: :model, ont: true do

  let(:config)            { Pipelines.configure(Pipelines.load_yaml) }
  let(:pipeline_config)   { config.ont.covid }
  let(:request)           { create(:ont_request_with_tags, tags_count: 1, library: create(:ont_flowcell).library) }
  let(:message)           { Messages::Message.new(object: request, configuration: pipeline_config.message) }

  it 'should have a lims' do
    expect(message.content[:lims]).to eq(pipeline_config.lims)
  end

  it 'should have a key' do
    expect(message.content[pipeline_config.key]).to_not be_empty
  end

  describe 'key' do

    let(:key) { message.content[pipeline_config.key] }

    let(:timestamp) { Time.parse('Mon, 08 Apr 2019 09:15:11 UTC +00:00') }

    before(:each) do
      allow(Time).to receive(:current).and_return timestamp
    end

    it 'must have a last_updated field' do
      expect(key[:last_updated]).to eq(timestamp)
    end

    it 'must have an id_flowcell_lims' do
      expect(key[:id_flowcell_lims]).to eq(request.library.flowcell.id)
    end

    it 'must have a sample_uuid' do
      expect(key[:sample_uuid]).to eq(request.external_id)
    end

    it 'must have a study_uuid' do
      expect(key[:study_uuid]).to eq("test study id")
    end

    it 'must have an experiment_name' do
      expect(key[:experiment_name]).to eq(request.library.flowcell.run.id)
    end

    it 'must have an instrument_name' do
      expect(key[:instrument_name]).to eq("GridION")
    end

    it 'must have an instrument_slot' do
      expect(key[:instrument_slot]).to eq(request.library.flowcell.position)
    end

    it 'must have a pipeline_id_lims' do
      expect(key[:pipeline_id_lims]).to eq("test value")
    end

    it 'must have a tag_identifier' do
      expect(key[:tag_identifier]).to eq(request.tags.first.id)
    end

    it 'must have a tag_sequence' do
      expect(key[:tag_sequence]).to eq(request.tags.first.oligo)
    end

    it 'must have a tag_set_id_lims' do
      expect(key[:tag_set_id_lims]).to eq(request.tags.first.tag_set.id)
    end

    it 'must have a tag_set_id_lims' do
      expect(key[:tag_set_name]).to eq(request.tags.first.tag_set.name)
    end

    it 'must have a tag2_identifier' do
      expect(key[:tag2_identifier]).to eq("")
    end

    it 'must have a tag2_sequence' do
      expect(key[:tag2_sequence]).to eq("")
    end

    it 'must have a tag2_set_id_lims' do
      expect(key[:tag2_set_id_lims]).to eq("")
    end

    it 'must have a tag2_set_name' do
      expect(key[:tag2_set_name]).to eq("")
    end
  end
end