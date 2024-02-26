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

  context 'with a valid source' do
    let(:attributes) { { source: 'traction-ui.sequencescape' } }

    it { is_expected.to be_valid }

    describe '#construct_resources!' do
      it 'associates requests with this reception' do
        expect { reception.construct_resources! }.to change { reception.requests.count }.by(1)
      end
    end
  end
end
