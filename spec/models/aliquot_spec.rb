# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Aliquot do
  it 'is invalid without volume' do
    expect(build(:aliquot, volume: nil)).not_to be_valid
  end

  it 'is invalid without concentration' do
    expect(build(:aliquot, concentration: nil)).not_to be_valid
  end

  it 'is invalid without template_prep_kit_box_barcode' do
    expect(build(:aliquot, template_prep_kit_box_barcode: nil)).not_to be_valid
  end

  it 'is valid without an insert_size' do
    # Insert size may not be known at the time of creation so we don't validate it
    expect(build(:aliquot, insert_size: nil)).to be_valid
  end

  it 'is valid without volume, concentration, template_prep_kit_box_barcode and insert_size if source is a Pacbio::Request and its a primary aliquot' do
    expect(build(:aliquot, volume: nil, concentration: nil, template_prep_kit_box_barcode: nil, insert_size: nil, source: build(:pacbio_request), aliquot_type: :primary)).to be_valid
  end

  it 'is invalid if volume is not a positive number' do
    expect(build(:aliquot, volume: 'a word')).not_to be_valid
    expect(build(:aliquot, volume: '-1')).not_to be_valid
  end

  it 'is invalid if concentration is not a positive number' do
    expect(build(:aliquot, concentration: 'a word')).not_to be_valid
    expect(build(:aliquot, concentration: '-1')).not_to be_valid
  end

  it 'is invalid if insert_size is not a positive number' do
    expect(build(:aliquot, insert_size: 'a word')).not_to be_valid
    expect(build(:aliquot, insert_size: '-1')).not_to be_valid
  end

  it 'has a valid list of states' do
    expect(described_class.states).to eq({ 'created' => 0, 'used' => 1 })
  end

  it 'is invalid without a state' do
    expect { create(:aliquot, state: nil) }.to raise_error(ActiveRecord::NotNullViolation)
  end

  it 'has a valid list of aliquot_types' do
    expect(described_class.aliquot_types).to eq({ 'primary' => 0, 'derived' => 1 })
  end

  it 'is invalid without an aliquot_type' do
    expect { create(:aliquot, aliquot_type: nil) }.to raise_error(ActiveRecord::NotNullViolation)
  end

  it 'can have a tag' do
    tag = create(:tag)
    expect(build(:aliquot, tag:).tag).to eq(tag)
  end

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_library }

    it_behaves_like 'uuidable'
  end

  it 'is invalid without a source' do
    aliquot = build(:aliquot, source: nil)
    expect(aliquot).not_to be_valid
    expect(aliquot.errors[:source]).to include('must exist')
  end

  it 'can have a library through the used_by relation' do
    pacbio_library = create(:pacbio_library)
    aliquot = build(:aliquot, used_by: pacbio_library)
    expect(aliquot).to be_valid
    expect(aliquot.used_by).to eq(pacbio_library)
  end

  describe '#valid?(:run_creation)' do
    subject { build(:aliquot, params).valid?(:run_creation) }

    context 'when volume is nil' do
      let(:params) { { volume: nil } }

      it { is_expected.to be false }
    end

    context 'when concentration is nil' do
      let(:params) { { concentration: nil } }

      it { is_expected.to be false }
    end

    context 'when insert_size is nil' do
      let(:params) { { insert_size: nil } }

      it { is_expected.to be false }
    end

    context 'when template_prep_kit_box_barcode is nil' do
      let(:params) { { template_prep_kit_box_barcode: nil } }

      it { is_expected.to be false }
    end

    context 'when volume is 12.0' do
      let(:params) { { volume: 12.0 } }

      it { is_expected.to be true }
    end

    context 'when concentration is 12.0' do
      let(:params) { { concentration: 12.0 } }

      it { is_expected.to be true }
    end

    context 'when insert_size is 12.0' do
      let(:params) { { insert_size: 12.0 } }

      it { is_expected.to be true }
    end

    context 'when template_prep_kit_box_barcode is "1234"' do
      let(:params) { { template_prep_kit_box_barcode: '1234' } }

      it { is_expected.to be true }
    end
  end

  describe '#sample_sheet_behaviour' do
    it 'returns the hidden sample sheet behaviour when the aliquot has a hidden tag' do
      aliquot = create(:aliquot, tag: create(:hidden_tag))
      expect(aliquot.sample_sheet_behaviour.class).to eq(SampleSheetBehaviour::Hidden)
    end

    it 'returns the default sample sheet behaviour when the aliquot has a standard tag' do
      aliquot = create(:aliquot, tag: create(:tag))
      expect(aliquot.sample_sheet_behaviour.class).to eq(SampleSheetBehaviour::Default)
    end

    it 'returns the untagged sample sheet behaviour when the aliquot does not have a tag' do
      aliquot = create(:aliquot, tag: nil)
      expect(aliquot.sample_sheet_behaviour.class).to eq(SampleSheetBehaviour::Untagged)
    end
  end

  describe '#collection?' do
    let(:aliquot) { create(:aliquot) }

    it 'always be false' do
      expect(aliquot).not_to be_collection
    end
  end
end
