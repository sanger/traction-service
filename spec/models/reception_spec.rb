# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reception do
  subject { build(:reception, attributes) }

  context 'without a source' do
    let(:attributes) { { source: nil } }

    it { is_expected.not_to be_valid }
  end

  context 'with a source' do
    let(:attributes) { { source: 'traction-ui.sequencescape' } }

    it { is_expected.to be_valid }
  end

  # We get a bit strict with validation, mainly to stop us getting a
  # mix of styles should we have other apps posting to our API
  context 'with a space' do
    let(:attributes) { { source: 'traction-ui sequencescape' } }

    it { is_expected.not_to be_valid }
  end

  context 'with an underscore' do
    let(:attributes) { { source: 'traction_ui.sequencescape' } }

    it { is_expected.not_to be_valid }
  end

  context 'with uppercase' do
    let(:attributes) { { source: 'traction-ui.Sequencescape' } }

    it { is_expected.not_to be_valid }
  end

  context 'without plate_attributes or tubes_attributes' do
    let(:attributes) { { plates_attributes: [], tubes_attributes: [] } }

    it { is_expected.not_to be_valid }
  end

  describe '#construct_resources!' do
    subject(:construct_resources) { reception.construct_resources! }

    let(:reception) { build(:reception, plates_attributes:, tubes_attributes:) }
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
      let(:library_type) { create(:library_type, :ont) }
      let(:data_type) { create(:data_type, :ont) }

      let(:request_parameters) do
        attributes_for(:ont_request)
        .merge(
          library_type: library_type.name,
          data_type: data_type.name
        )
      end

      it 'associates the requests with this reception' do
        construct_resources

        expect(reception.requests.count).to eq 5
      end
    end
  end
end
