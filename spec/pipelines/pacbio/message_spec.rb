require "rails_helper"

RSpec.describe 'PacBio', type: :model, pacbio: true do

  let(:config)        { Pipelines.configure(Rails.configuration.pipelines) }
  let(:pacbio_config) { config.pacbio }
  # let(:well)          { create(:pacbio_well_with_library) }
  let(:plate)         { create(:pacbio_plate_with_wells)}
  # let(:message)       { Messages::Message.new(object: well, configuration: pacbio_config.message) }
  let(:message)       { Messages::Message.new(object: plate, configuration: pacbio_config.message) }

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

    it 'must have a id_pac_bio_run_lims' do
      expect(key[:id_pac_bio_run_lims]).to eq(plate.run.id)
    end

    it 'must have a pac_bio_run_uuid' do
      expect(key[:pac_bio_run_uuid]).to eq(plate.run.uuid)
    end

    it 'must have a plate barcode' do
      expect(key[:plate_barcode]).to eq(plate.barcode)
    end

    it 'must have a plate uuid' do
      expect(key[:plate_uuid]).to eq(plate.uuid)
    end

    it 'must have a last_updated field' do
      expect(key[:last_updated]).to eq(timestamp)
    end

    context 'wells' do

      let(:plate_well)  { plate.wells.first }
      let(:message_well) { key[:wells].first }

      it 'will have the correct number' do
        expect(key[:wells].length).to eq(plate.wells.count)
      end

      context 'each' do

        it 'must have a well label' do
          expect(message_well[:well_label]).to eq(plate_well.position)
        end

        it 'must have a well uuid lims' do
          expect(message_well[:well_uuid_lims]).to eq(plate_well.uuid)
        end

      end

      #TODO: change library into libraries which will involve model changes
      context 'samples' do

        let(:well_library)     { plate_well.library }
        let(:message_sample)   { message_well[:samples].first }

        it 'will have the correct number' do
          expect(message_well[:samples].length).to eq(1)
        end

        context 'each' do

          it 'must have a cost code' do
            expect(message_sample[:cost_code]).to eq(well_library.request.cost_code)
          end

          it 'must have a library tube id' do
            expect(message_sample[:pac_bio_library_tube_id_lims]).to eq(well_library.id)
          end

          it 'must have a well uuid lims' do
            expect(message_sample[:pac_bio_library_tube_uuid]).to eq(well_library.uuid)
          end

          it 'must have a sample_uuid' do
            expect(message_sample[:sample_uuid]).to eq(well_library.request.sample.external_id)
          end

          it 'must have a study_uuid' do
            expect(message_sample[:study_uuid]).to eq(well_library.request.external_study_id)
          end

          it 'must have a tag sequence' do
            expect(message_sample[:tag_sequence]).to eq(well_library.tag.oligo)
          end

          it 'must have a tag group id' do
            expect(message_sample[:tag_set_id_lims]).to eq(well_library.tag.group_id)
          end

          it 'must have a tag identifier' do
            expect(message_sample[:tag_identifier]).to eq(well_library.tag.id)
          end

          it 'must have a tag set name' do
            expect(message_sample[:tag_set_name]).to eq('pacbio')
          end

        end

      end
    end

  end

end