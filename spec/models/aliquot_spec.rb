# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Aliquot do
  it 'is invalid without volume' do
    aliquot = build(:aliquot, volume: nil)
    expect(aliquot).not_to be_valid
    expect(aliquot.errors[:volume]).to include("can't be blank")
  end

  it 'is invalid without concentration' do
    aliquot = build(:aliquot, concentration: nil)
    expect(aliquot).not_to be_valid
    expect(aliquot.errors[:concentration]).to include("can't be blank")
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

  skip 'is invalid without a source'
end
