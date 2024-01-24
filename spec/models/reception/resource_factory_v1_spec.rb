# frozen_string_literal: true

# DEPRECATE-Reception-V1:
# Delete this file

require 'rails_helper'

RSpec.describe Reception::ResourceFactoryV1 do
  subject(:resource_factory) { build(:reception_resource_factory_v1, request_attributes:) }

  let(:library_type) { create(:library_type, :ont) }
  let(:data_type) { create(:data_type, :ont) }

  describe '#valid?' do
    context 'with invalid samples' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample, name: nil),
          container: { type: 'tubes', barcode: 'NT1' }
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with unknown containers' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample),
          container: { type: 'elephant', barcode: 'NT1' }
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with invalid tubes' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample),
          container: { type: 'tubes' }
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with invalid wells' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample),
          container: { type: 'wells', barcode: 'DN1' }
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with invalid plates' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample),
          container: { type: 'wells', position: 'A1' }
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with invalid requests' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            data_type: data_type.name
          ),
          sample: attributes_for(:sample),
          container: { type: 'tubes', barcode: 'NT1' }
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with no requests' do
      let(:request_attributes) do
        []
      end

      it 'is not valid and returns a custom error message' do
        expect(resource_factory.valid?).to be(false)
        expect(resource_factory.errors.full_messages).to include('Request attributes there are no new samples to import')
      end
    end

    context 'with duplicate containers' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample),
          container: { type: 'tubes', barcode: 'NT1' }
        }, {
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample),
          container: { type: 'tubes', barcode: 'NT1' }
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with everything in order' do
      let(:request_attributes) do
        [{
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample),
          container: { type: 'tubes', barcode: 'NT1' }
        }]
      end

      it { is_expected.to be_valid }
    end
  end

  describe '#construct_resources!' do
    subject(:construct_resources) do
      resource_factory.construct_resources!
    end

    let(:resource_factory) do
      build(:reception_resource_factory_v1, request_attributes:)
    end
    let(:existing_tube) { attributes_for(:tube, :with_barcode) }
    let(:new_plate_barcode) { generate(:barcode) }
    let(:existing_plate_barcode) { generate(:barcode) }
    let(:existing_plate) { attributes_for(:plate, barcode: existing_plate_barcode) }
    let(:existing_well_a1) { attributes_for(:well, position: 'A1', barcode: existing_plate_barcode) }
    let(:existing_sample_a1) { attributes_for(:sample) }
    let(:existing_sample_b1) { attributes_for(:sample) }
    let(:request_attributes) do
      [{
        # New sample in new tube (valid)
        request: request_parameters,
        sample: attributes_for(:sample),
        container: { type: 'tubes', **attributes_for(:tube, :with_barcode) }
      }, {
        # New sample in existing tube (invalid)
        request: request_parameters,
        sample: attributes_for(:sample),
        container: { type: 'tubes', **existing_tube }
      }, {
        # New well in new plate with new sample (valid)
        request: request_parameters,
        sample: attributes_for(:sample),
        container: { type: 'wells', **attributes_for(:well, position: 'A1', barcode: new_plate_barcode) }
      }, {
        # New well in new plate with existing sample (valid)
        request: request_parameters,
        sample: existing_sample_b1,
        container: { type: 'wells', **attributes_for(:well, position: 'B1', barcode: new_plate_barcode) }
      }, {
        # Existing well in existing plate with existing sample (invalid)
        request: request_parameters,
        sample: existing_sample_a1,
        container: { type: 'wells', **existing_well_a1 }
      }, {
        # New well in existing plate with new sample (valid)
        request: request_parameters,
        sample: attributes_for(:sample),
        container: { type: 'wells', **attributes_for(:well, position: 'C1', barcode: existing_plate_barcode) }
      }, {
        # New well in new plate with new sample (valid)
        request: request_parameters,
        sample: attributes_for(:sample),
        container: { type: 'wells', **attributes_for(:well, position: 'A1', barcode: generate(:barcode)) }
      }]
    end

    let(:reception) { resource_factory.reception }

    before do
      create(:tube, existing_tube)
      exists = create(:plate, existing_plate)
      create(:well, **existing_well_a1.except(:barcode), plate: exists)
      create(:sample, existing_sample_a1)
      create(:sample, existing_sample_b1)
    end

    context 'ont' do
      let(:request_parameters) do
        attributes_for(:ont_request).merge(
          library_type: library_type.name,
          data_type: data_type.name
        )
      end

      it 'creates 5 Requests' do
        expect { construct_resources }.to change(Request, :count).by(5)
      end

      it 'creates 5 ONT::Requests' do
        expect { construct_resources }.to change(Ont::Request, :count).by(5)
      end

      it 'creates new samples' do
        expect { construct_resources }.to change(Sample, :count).by(4)
      end

      it 'creates new tubes' do
        expect { construct_resources }.to change(Tube, :count).by(1)
      end

      it 'creates new plates' do
        expect { construct_resources }.to change(Plate, :count).by(2)
      end

      it 'creates new wells' do
        expect { construct_resources }.to change(Well, :count).by(4)
      end

      it 'associates the requests with the reception' do
        construct_resources
        expect(reception.requests.reload.count).to eq 5
      end
    end

    context 'pacbio' do
      let(:library_type) { create(:library_type, :pacbio) }
      let(:request_parameters) do
        attributes_for(:pacbio_request).merge(
          library_type: library_type.name
        )
      end

      it 'creates 5 Requests' do
        expect { construct_resources }.to change(Request, :count).by(5)
      end

      it 'creates 5 Pacbio::Requests' do
        expect { construct_resources }.to change(Pacbio::Request, :count).by(5)
      end

      it 'creates 5 Aliquots' do
        # 5 requests, 1 aliquot per Pacbio::Request
        expect { construct_resources }.to change(Aliquot, :count).by(5)
      end

      it 'creates new samples' do
        expect { construct_resources }.to change(Sample, :count).by(4)
      end

      it 'creates new tubes' do
        expect { construct_resources }.to change(Tube, :count).by(1)
      end

      it 'creates new plates' do
        expect { construct_resources }.to change(Plate, :count).by(2)
      end

      it 'creates new wells' do
        expect { construct_resources }.to change(Well, :count).by(4)
      end

      it 'associates the requests with the reception' do
        construct_resources
        expect(reception.requests.reload.count).to eq 5
      end
    end

    context 'saphyr' do
      let(:library_type) { create(:library_type, :saphyr) }
      let(:request_parameters) do
        attributes_for(:saphyr_request).merge(
          library_type: library_type.name
        )
      end

      it 'creates 5 Requests' do
        expect { construct_resources }.to change(Request, :count).by(5)
      end

      it 'creates 5 Saphyr::Requests' do
        expect { construct_resources }.to change(Saphyr::Request, :count).by(5)
      end

      it 'creates new samples' do
        expect { construct_resources }.to change(Sample, :count).by(4)
      end

      it 'creates new tubes' do
        expect { construct_resources }.to change(Tube, :count).by(1)
      end

      it 'creates new plates' do
        expect { construct_resources }.to change(Plate, :count).by(2)
      end

      it 'creates new wells' do
        expect { construct_resources }.to change(Well, :count).by(4)
      end

      it 'associates the requests with the reception' do
        construct_resources
        expect(reception.requests.reload.count).to eq 5
      end
    end
  end
end
