require "rails_helper"

# Temporary until the classes are added
class MockWell

  def library
    @library ||= Library.new
  end

  def plate
    @plate ||= Plate.new
  end

  def position
    'A1'
  end

  def uuid
    '01099dd4-7590-4b2d-828d-4ee0541ac065'
  end

  class Library

    def sample
      @sample ||= Sample.new
    end

    def tag_sequence
      'ACGT'
    end

    def id
      1
    end

    def name
      'library1'
    end

    def uuid
      'de200ad1-fa96-4145-b7d0-4c868b1aac9b'
    end

    class Sample

      def cost_code
        'PSD-123'
      end

      def external_id
        '687b1c17-9b3e-4266-9d39-e6cd63f0f14b'
      end

      def external_study_id
        '74bb531a-0fa0-4d17-87c1-10e340c3457a'
      end

    end
  end

  class Plate

    def run
      @run ||= Run.new
    end

    def barcode
      'TRAC-1234567'
    end

    def uuid
      '6622853f-8581-4ef0-aadc-80b2af224ee8'
    end

    class Run

      def id
        1
      end

      def uuid
        '85ccc7f5-152c-4a0a-8940-f7ed0b8f9fb8'
      end
    end

  end
end

RSpec.describe 'PacBio', type: :model do

  let(:config)        { Pipelines.configure(Rails.configuration.pipelines) }
  let(:pacbio_config) { config.pacbio }
  let(:well)          { MockWell.new }
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
      expect(key[:sample_uuid]).to eq(well.library.sample.external_id)
    end

    it 'must have a study_uuid' do
      expect(key[:study_uuid]).to eq(well.library.sample.external_study_id)
    end

    it 'must have a id_pac_bio_run_lims' do
      expect(key[:id_pac_bio_run_lims]).to eq(well.plate.run.id)
    end

    it 'must have a pac_bio_run_uuid' do
      expect(key[:pac_bio_run_uuid]).to eq(well.plate.run.uuid)
    end

    it 'must have a cost code' do
      expect(key[:cost_code]).to eq(well.library.sample.cost_code)
    end

    it 'must have a tag sequence' do
      expect(key[:tag_sequence]).to eq(well.library.tag_sequence)
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
      expect(key[:pac_bio_library_tube_name]).to eq(well.library.name)

    end



  end

end