# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reception::ResourceFactory do
  subject(:resource_factory) { build(:reception_resource_factory, tubes_attributes:, plates_attributes:, pool_attributes:) }

  let(:tubes_attributes) { [] }
  let(:plates_attributes) { [] }
  let(:pool_attributes) { nil }
  let(:library_type) { create(:library_type, :ont) }
  let(:data_type) { create(:data_type, :ont) }

  describe '#valid?' do
    context 'with invalid samples' do
      let(:tubes_attributes) do
        [{
          type: 'tubes',
          barcode: generate(:barcode),
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample, name: nil)
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with invalid tubes' do
      let(:tubes_attributes) do
        [{
          type: 'tubes',
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample)
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with invalid wells' do
      let(:plates_attributes) do
        [{
          type: 'plates',
          barcode: 'DN1',
          wells_attributes: [{
            request: attributes_for(:ont_request).merge(
              library_type: library_type.name,
              data_type: data_type.name
            ),
            sample: attributes_for(:sample)
          }]
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with invalid plates' do
      let(:plates_attributes) do
        [{
          type: 'plates',
          wells_attributes: [{
            position: 'A1',
            request: attributes_for(:ont_request).merge(
              library_type: library_type.name,
              data_type: data_type.name
            ),
            sample: attributes_for(:sample)
          }]
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with invalid requests' do
      let(:tubes_attributes) do
        [{
          type: 'tubes',
          request: attributes_for(:ont_request).merge(
            data_type: data_type.name
          ),
          sample: attributes_for(:sample)
        }]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with an invalid pool' do
      let(:tubes_attributes) do
        [{
          type: 'tubes',
          barcode: 'NT1',
          request: attributes_for(:ont_request).merge(
            library_type: library_type.name,
            data_type: data_type.name
          ),
          sample: attributes_for(:sample)
        }]
      end

      let(:pool_attributes) do
        {
          barcode: 'test-barcode',
          volume: 1,
          concentration: -1,
          insert_size: 1
        }
      end

      it { is_expected.not_to be_valid }
    end

    context 'with no requests' do
      let(:tubes_attributes) do
        []
      end
      let(:plates_attributes) do
        []
      end

      it 'is not valid and returns a custom error message' do
        expect(resource_factory.valid?).to be(false)
        expect(resource_factory.errors.full_messages).to include('Requests there are no new samples to import')
      end
    end

    context 'with duplicate tubes' do
      let(:tubes_attributes) do
        [
          {
            type: 'tubes',
            barcode: 'NT1',
            request: attributes_for(:ont_request).merge(
              library_type: library_type.name,
              data_type: data_type.name
            ),
            sample: attributes_for(:sample)
          },
          {
            type: 'tubes',
            barcode: 'NT1',
            request: attributes_for(:ont_request).merge(
              library_type: library_type.name,
              data_type: data_type.name
            ),
            sample: attributes_for(:sample)
          }
        ]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with duplicate wells' do
      let(:plates_attributes) do
        [
          {
            type: 'plates',
            barcode: 'DN1',
            wells_attributes: [
              {
                position: 'A1',
                request: attributes_for(:ont_request).merge(
                  library_type: library_type.name,
                  data_type: data_type.name
                ),
                sample: attributes_for(:sample)
              },
              {
                position: 'A1',
                request: attributes_for(:ont_request).merge(
                  library_type: library_type.name,
                  data_type: data_type.name
                ),
                sample: attributes_for(:sample)
              }
            ]
          }
        ]
      end

      it { is_expected.not_to be_valid }
    end

    context 'with everything in order' do
      let(:tubes_attributes) do
        [
          {
            type: 'tubes',
            barcode: 'NT1',
            request: attributes_for(:ont_request).merge(
              library_type: library_type.name,
              data_type: data_type.name
            ),
            sample: attributes_for(:sample)
          }
        ]
      end
      let(:plates_attributes) do
        [{
          type: 'plates',
          barcode: 'DN1',
          wells_attributes: [{
            position: 'A1',
            request: attributes_for(:ont_request).merge(
              library_type: library_type.name,
              data_type: data_type.name
            ),
            sample: attributes_for(:sample)
          }]
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
      build(:reception_resource_factory, plates_attributes:, tubes_attributes:)
    end

    let(:existing_tube) { attributes_for(:tube, :with_barcode) }
    let(:new_tube_barcode) { generate(:barcode) }
    let(:new_plate_barcode) { generate(:barcode) }
    let(:new_plate_barcode_2) { generate(:barcode) }
    let(:existing_plate) { attributes_for(:plate, barcode: generate(:barcode)) }
    let(:existing_well_a1) { attributes_for(:well, position: 'A1', barcode: existing_plate.fetch(:barcode)) }
    let(:existing_sample) { attributes_for(:sample) }
    let(:tubes_attributes) do
      [{
        # New sample in new tube (valid)
        type: 'tubes',
        barcode: new_tube_barcode,
        request: request_parameters,
        sample: attributes_for(:sample)
      }, {
        # New sample in existing tube (invalid)
        type: 'tubes',
        **existing_tube,
        request: request_parameters,
        sample: attributes_for(:sample)
      }]
    end
    let(:plates_attributes) do
      [
        {
          type: 'plates',
          barcode: new_plate_barcode,
          wells_attributes: [
            # New well in new plate with new sample (valid)
            {
              position: 'A1',
              request: request_parameters,
              sample: attributes_for(:sample)
            },
            # New well in new plate with existing sample (valid)
            {
              position: 'B1',
              request: request_parameters,
              sample: existing_sample
            }
          ]
        },
        {
          type: 'plates',
          barcode: existing_plate.fetch(:barcode),
          wells_attributes: [
            # Existing well in existing plate with existing sample (invalid)
            {
              position: existing_well_a1.fetch(:position),
              request: request_parameters,
              sample: existing_sample
            },
            # New well in existing plate with new sample (valid)
            {
              position: 'C1',
              request: request_parameters,
              sample: attributes_for(:sample)
            }
          ]
        },
        {
          type: 'plates',
          barcode: new_plate_barcode_2,
          wells_attributes: [
            # New well in new plate with new sample (valid)
            {
              position: 'A1',
              request: request_parameters,
              sample: attributes_for(:sample)
            }
          ]
        }
      ]
    end

    before do
      create(:tube, existing_tube)
      exists = create(:plate, existing_plate)
      create(:well, **existing_well_a1.except(:barcode), plate: exists)
      create(:sample, existing_sample)
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

      it 'returns the correct labware' do
        labware = construct_resources
        expected_data = {
          existing_plate.fetch(:barcode) => {
            imported: 'partial',
            errors: ["#{existing_well_a1.fetch(:position)} already has a sample"]
          },
          new_plate_barcode => {
            imported: 'success',
            errors: []
          },
          new_plate_barcode_2 => {
            imported: 'success',
            errors: []
          },
          existing_tube.fetch(:barcode) => {
            imported: 'failed',
            errors: ['Tube already has a sample']
          },
          new_tube_barcode => {
            imported: 'success',
            errors: []
          }
        }
        expect(labware).to eq(expected_data)
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

      it 'returns the correct labware' do
        labware = construct_resources
        expected_data = {
          existing_plate.fetch(:barcode) => {
            imported: 'partial',
            errors: ["#{existing_well_a1.fetch(:position)} already has a sample"]
          },
          new_plate_barcode => {
            imported: 'success',
            errors: []
          },
          new_plate_barcode_2 => {
            imported: 'success',
            errors: []
          },
          existing_tube.fetch(:barcode) => {
            imported: 'failed',
            errors: ['Tube already has a sample']
          },
          new_tube_barcode => {
            imported: 'success',
            errors: []
          }
        }
        expect(labware).to eq(expected_data)
      end
    end
  end

  describe '#compound_sample_tubes_attributes=' do
    define_negated_matcher :not_change, :change

    let(:library_type) { create(:library_type, :pacbio) }
    let(:request_parameters) do
      attributes_for(:pacbio_request).merge(
        library_type: library_type.name
      )
    end
    let(:compound_sample_tubes_attributes) do
      [{
        barcode: 'tube-123',
        request: request_parameters,
        samples: [
          {
            name: 'compound_sample_1',
            external_id: 'uuid-1',
            species: 'human',
            supplier_name: 'supplier_name'
          },
          {
            name: 'compound_sample_2',
            external_id: 'uuid-2',
            species: 'human',
            supplier_name: 'supplier_name'
          }
        ]
      },
       {
         barcode: 'tube-1234',
         request: request_parameters,
         samples: [
           {
             name: 'compound_sample_3',
             external_id: 'uuid-1',
             species: 'human',
             supplier_name: 'supplier_name_2'
           },
           {
             name: 'compound_sample_4',
             external_id: 'uuid-2',
             species: 'human',
             supplier_name: 'supplier_name_2'
           }
         ]
       }]
    end

    it 'creates compound samples and requests' do
      aggregate_failures do
        expect do
          resource_factory.compound_sample_tubes_attributes = compound_sample_tubes_attributes
          resource_factory.construct_resources!
        end.to change(Request, :count).by(2)
                                      .and change(Sample, :count).by(2)
      end
    end

    it 'publishes the compound sample messages' do
      expect(Messages).to receive(:publish).twice
      resource_factory.compound_sample_tubes_attributes = compound_sample_tubes_attributes
    end

    it 'uses existing samples if sample with supplier name exists' do
      create(:sample, name: compound_sample_tubes_attributes[0][:samples][0][:supplier_name])
      create(:sample, name: compound_sample_tubes_attributes[1][:samples][0][:supplier_name])

      expect(Messages).to receive(:publish).twice
      expect do
        resource_factory.compound_sample_tubes_attributes = compound_sample_tubes_attributes
        resource_factory.construct_resources!
      end.to change(Request, :count).by(2)
                                    .and not_change(Sample, :count)
    end
  end
end
