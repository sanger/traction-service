require 'rails_helper'

RSpec.describe Ont::PlateWithSamplesFactory, type: :model, ont: true do
  context 'serialisation' do
    let(:factory) { Ont::PlateWithSamplesFactory.new }
    let(:time) { DateTime.now }

    before do
      allow(DateTime).to receive(:now).and_return(time)
    end

    context 'ont_request_data' do
      let(:request) { create(:ont_request) }
      let(:tag_id) { 'test tag id' }
  
      it 'returns expected serialisation' do
        ont_request_data = factory.ont_request_data(request, tag_id)
        expect(ont_request_data).to eq({
          ont_request: {
            uuid: request.uuid,
            external_id: request.external_id,
            name: request.name,
            created_at: time,
            updated_at: time
          },
          tag_id: tag_id
        })
      end
    end
  
    context 'well_data' do
      let(:well) { create(:well) }
      let(:request_data) { 'test request data' }
  
      it 'returns expected serialisation' do
        well_data = factory.well_data(well, request_data)
        expect(well_data).to eq({
          well: {
            position: well.position,
            created_at: time,
            updated_at: time
          },
          request_data: request_data
        })
      end
    end
  
    context 'plate_data' do
      let(:plate) { create(:plate) }
      let(:well_data) { 'test well data' }
  
      it 'returns expected serialisation' do
        plate_data = factory.plate_data(plate, well_data)
        expect(plate_data).to eq({
          plate: {
            barcode: plate.barcode,
            created_at: time,
            updated_at: time
          },
          well_data: well_data
        })
      end
    end
  end

  context 'process' do
    let(:attributes) { 'some test attributes' }
    let(:factory) { Ont::PlateWithSamplesFactory.new(attributes) }

    it 'initialises a new plate factory' do
      expect(Ont::PlateFactory).to receive(:new).with(attributes)
      factory.process
    end
  end
end
