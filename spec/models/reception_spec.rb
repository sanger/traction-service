# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reception do
  subject(:reception) { build(:reception, attributes) }

  context 'without a source' do
    let(:attributes) { { source: nil } }

    it { is_expected.not_to be_valid }
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

  context 'with an invalid sample' do
    let(:attributes) do
      { plates_attributes: [
        {
          type: 'plates',
          barcode: generate(:barcode),
          wells_attributes: [
            {
              position: 'A1',
              request: { library_type: 'lib', data_type: 'dt', cost_code: generate(:cost_code), external_study_id: generate(:external_study_id) },
              sample: { name: generate(:sample_name), species: 'Human', external_id: generate(:uuid), retention_instruction: 'invalid_instruction' }
            }
          ]
        }
      ], tubes_attributes: [] }
    end

    it 'raises an ArgumentError' do
      expect { reception.valid? }.to raise_error(ArgumentError)
    end
  end

  context 'with a valid source' do
    let(:attributes) { { source: 'traction-ui.sequencescape' } }

    it { is_expected.to be_valid }

    describe '#construct_resources!' do
      it 'associates requests with this reception' do
        expect { reception.construct_resources! }.to change { reception.requests.count }.by(1)
      end
    end
  end

  describe '#publish_source?' do
    describe 'with a publishable source' do
      let(:attributes) { { source: Reception::TOL_LAB_SHARE_SOURCE } }

      it 'returns true' do
        expect(reception.publish_source?).to be(true)
      end
    end

    describe 'with a traction-ui source' do
      let(:attributes) { { source: 'traction-ui.sequencescape' } }

      it 'returns false' do
        expect(reception.publish_source?).to be(false)
      end
    end

    describe 'with an empty source' do
      let(:attributes) { { source: nil } }

      it 'returns false' do
        expect(reception.publish_source?).to be(false)
      end
    end
  end
end
