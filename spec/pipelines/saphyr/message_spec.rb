require "rails_helper"

RSpec.describe 'Saphyr', type: :model, saphyr: true do

  let(:config)            { Pipelines.configure(Rails.configuration.pipelines) }
  let(:pipeline_config)   { config.saphyr }
  let(:flowcell)          { create(:saphyr_flowcell_with_library) }
  let(:message)           { Messages::Message.new(object: flowcell, configuration: pipeline_config.message) }

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

    it 'must have a sample_uuid' do
      expect(key[:sample_uuid]).to eq(flowcell.library.request.sample.external_id)
    end

    it 'must have a study_uuid' do
      expect(key[:study_uuid]).to eq(flowcell.library.request.external_study_id)
    end

    it 'must have an experiment_name' do
      expect(key[:experiment_name]).to eq(flowcell.chip.run.name)
    end

    it 'must have an enzyme_name' do
      expect(key[:enzyme_name]).to eq(flowcell.library.enzyme.name)
    end

    it 'must have a chip_barcode' do
      expect(key[:chip_barcode]).to eq(flowcell.chip.barcode)
    end

    it 'must have a chip_serialnumber' do
      expect(key[:chip_serialnumber]).to eq(flowcell.chip.serial_number)
    end

    it 'must have a position' do
      expect(key[:position]).to eq(flowcell.position)
    end

    it 'must have an id_library_lims' do
      expect(key[:id_library_lims]).to eq(flowcell.library.id)
    end

    it 'must have a id_flowcell_lims' do
      expect(key[:id_flowcell_lims]).to eq(flowcell.id)
    end

    it 'must have an instrument_name' do
      expect(key[:instrument_name]).to eq('saphyr')
    end

  end

end