# frozen_string_literal: true

require 'rails_helper'
require './spec/support/read_only'

RSpec.describe Ont::Request, ont: true do
  describe '#valid?' do
    subject { build(:ont_request, attributes) }

    context 'with all required attributes' do
      let(:attributes) { {} }

      it { is_expected.to be_valid }
    end

    context 'without a costcode' do
      let(:attributes) { { cost_code: '' } }

      it { is_expected.not_to be_valid }
    end

    context 'without an external_study_id' do
      let(:attributes) { { external_study_id: '' } }

      it { is_expected.not_to be_valid }
    end

    context 'with a non uuid external_study_id' do
      let(:attributes) { { external_study_id: '2' } }

      it { is_expected.not_to be_valid }
    end

    context 'without a number of flowcells' do
      let(:attributes) { { number_of_flowcells: '' } }

      it { is_expected.not_to be_valid }
    end

    context 'with a negative of flowcells' do
      let(:attributes) { { number_of_flowcells: -3 } }

      it { is_expected.not_to be_valid }
    end

    context 'with a non-integer of flowcells' do
      let(:attributes) { { number_of_flowcells: 3.5 } }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#library_type' do
    subject(:request) { build(:ont_request, attributes) }

    context 'when set' do
      let(:library_type) { build(:library_type, :ont) }
      let(:attributes) { { library_type: } }

      it { expect(request.library_type).to eq library_type }
      it { is_expected.to be_valid }
    end

    context 'when from a different pipeline' do
      let(:library_type) { build(:library_type, :pacbio) }
      let(:attributes) { { library_type: } }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#data_type' do
    subject { build(:ont_request, attributes).data_type }

    context 'when set' do
      let(:data_type) { build(:data_type, :ont) }
      let(:attributes) { { data_type: } }

      it { is_expected.to eq data_type }
    end
  end

  context 'material' do
    let(:material_model) { :ont_request }

    it_behaves_like 'material'
  end
end
