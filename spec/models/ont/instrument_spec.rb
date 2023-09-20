# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ont::Instrument, :ont do
  describe '#create' do
    it 'is possible to create a new instrument record' do
      expect { create(:ont_instrument) }.to change(described_class, :count).by(1)
    end
  end

  describe 'validation' do
    it 'has a unique name' do
      existing = create(:ont_instrument)
      expect(build(:ont_instrument, name: existing.name)).not_to be_valid
    end
  end

  it 'has a UUID field' do
    instrument = create(:ont_instrument)
    expect(instrument.has_attribute?(:uuid)).to be true
    expect(instrument.uuid).to be_present
  end
end
