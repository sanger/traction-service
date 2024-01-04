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

  it 'is invalid without an insert_size' do
    expect(build(:aliquot, insert_size: nil)).not_to be_valid
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
end
