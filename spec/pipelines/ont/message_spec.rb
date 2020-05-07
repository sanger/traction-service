require "rails_helper"

RSpec.describe 'Ont', type: :model, ont: true do

  let(:config)            { Pipelines.configure(Pipelines.load_yaml) }
  let(:pipeline_config)   { config.ont }
  let(:library_request)   { create(:ont_library_request, library: create(:ont_flowcell).library) }
  let(:message)           { Messages::Message.new(object: library_request, configuration: pipeline_config.message) }

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

    it 'must have a updated_at field' do
      expect(key[:updated_at]).to eq(timestamp)
    end

    it 'must have a sample_uuid' do
      expect(key[:sample_uuid]).to eq(library_request.request.sample.external_id)
    end

    it 'must have a study_uuid' do
      expect(key[:study_uuid]).to eq(library_request.request.external_study_id)
    end

    it 'must have an experiment_name' do
      expect(key[:experiment_name]).to eq(library_request.library.flowcell.run.id)
    end

    it 'must have an instrument_name' do
      expect(key[:instrument_name]).to eq(library_request.library.flowcell.run.instrument_name)
    end

    it 'must have an instrument_slot' do
      expect(key[:instrument_slot]).to eq(library_request.library.flowcell.position)
    end

    # TODO: test for the below when added to yaml
    # pipeline_id_lims:
    # library_preparation_type:
    # tag_identifier:
    # tag_sequence:
    # tag_set_id_lims:
    # tag_set_name:
    # tag2_identifier:
    # tag2_sequence:
    # tag2_set_id_lims:
    # tag2_set_name:

  end

end