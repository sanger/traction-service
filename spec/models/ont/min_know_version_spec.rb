# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ont::MinKnowVersion, ont: true do
  describe '#create' do
    it 'is possible to create a new record' do
      expect { create(:ont_min_know_version) }.to change(described_class, :count).by(1)
    end

    it 'errors if missing required fields' do
      expect { described_class.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'validation' do
    it 'name must be unique' do
      version = create(:ont_min_know_version)
      expect(build(:ont_min_know_version, name: version.name)).not_to be_valid
    end
  end

  describe '#active' do
    it 'will only show versions that are active' do
      create_list(:ont_min_know_version, 5)
      create_list(:ont_min_know_version, 2, active: false)

      expect(described_class.active.count).to eq(5)
    end
  end

  describe '#ordered_by_default' do
    it 'will show the default version first' do
      create_list(:ont_min_know_version, 5)
      default_version = create(:ont_min_know_version, default: true)
      ordered_by_default = described_class.ordered_by_default
      expect(ordered_by_default.count).to eq(6)
      expect(ordered_by_default.first).to eq(default_version)
    end
  end
end
