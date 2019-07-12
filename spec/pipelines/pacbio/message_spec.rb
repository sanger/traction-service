require "rails_helper"

RSpec.describe 'PacBio', type: :model, pacbio: true do

  let(:config)        { Pipelines.configure(Rails.configuration.pipelines) }
  let(:pacbio_config) { config.pacbio }
  let(:well)          { create(:pacbio_well_with_library) }
  let(:message)       { Messages::Message.new(object: well, configuration: pacbio_config.message) }

  it 'should have a lims' do
    expect(message.content[:lims]).to eq(pacbio_config.lims)
  end

  it 'should have a key' do
    expect(message.content[pacbio_config.key]).to_not be_empty
  end

  describe 'key' do

    let(:key) { message.content[pacbio_config.key] }

    let(:timestamp) { Time.parse('Mon, 08 Apr 2019 09:15:11 UTC +00:00') }

    before(:each) do
      allow(Time).to receive(:current).and_return timestamp
    end

    it 'must have a last_updated field' do
      expect(key[:last_updated]).to eq(timestamp)
    end

    it 'must have a sample_uuid' do
      expect(key[:sample_uuid]).to eq(well.library.request.sample.external_id)
    end

    it 'must have a study_uuid' do
      expect(key[:study_uuid]).to eq(well.library.request.external_study_id)
    end

    it 'must have a id_pac_bio_run_lims' do
      expect(key[:id_pac_bio_run_lims]).to eq(well.plate.run.id)
    end

    it 'must have a pac_bio_run_uuid' do
      expect(key[:pac_bio_run_uuid]).to eq(well.plate.run.uuid)
    end

    it 'must have a cost code' do
      expect(key[:cost_code]).to eq(well.library.request.cost_code)
    end

    it 'must have a tag sequence' do
      expect(key[:tag_sequence]).to eq(well.library.tag.oligo)
    end

    it 'must have a plate barcode' do
      expect(key[:plate_barcode]).to eq(well.plate.barcode)
    end

    it 'must have a plate uuid' do
      expect(key[:plate_uuid]).to eq(well.plate.uuid)
    end

    it 'must have a well label' do
      expect(key[:well_label]).to eq(well.position)
    end

    it 'must have a well uuid lims' do
      expect(key[:well_uuid_lims]).to eq(well.uuid)
    end

    it 'must have a library tube id' do
      expect(key[:pac_bio_library_tube_id_lims]).to eq(well.library.id)
    end

    it 'must have a library tube uuid' do
      expect(key[:pac_bio_library_tube_uuid]).to eq(well.library.uuid)
    end

    it 'must have a library tube name' do
      expect(key[:pac_bio_library_tube_name]).to eq(well.library.request.sample_name)
    end

  end

end