# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::SmrtLinkVersion, :pacbio do
  describe '#create' do
    it 'is possible to create a new record' do
      expect { create(:pacbio_smrt_link_version) }.to change(described_class, :count).by(1)
    end

    it 'is possible to create multiple smrt link versions' do
      smrt_link_version = create(:pacbio_smrt_link_version_with_options, option_count: 3)
      expect(smrt_link_version.smrt_link_options.length).to eq(3)
    end

    it 'errors if missing required fields' do
      expect { described_class.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'validation' do
    it 'name must be unique' do
      version = create(:pacbio_smrt_link_version)
      expect(build(:pacbio_smrt_link_version, name: version.name)).not_to be_valid
    end

    it 'name must be formatted correctly' do
      expect(build(:pacbio_smrt_link_version, name: 'v12')).to be_valid
      expect(build(:pacbio_smrt_link_version, name: 'v11_1')).to be_valid
      expect(build(:pacbio_smrt_link_version, name: 'v12_revio')).to be_valid

      expect(build(:pacbio_smrt_link_version, name: 'v1.1')).not_to be_valid
      expect(build(:pacbio_smrt_link_version, name: '10')).not_to be_valid
      expect(build(:pacbio_smrt_link_version, name: 'xx')).not_to be_valid
      expect(build(:pacbio_smrt_link_version, name: 'y.y.10')).not_to be_valid
      expect(build(:pacbio_smrt_link_version, name: 'vy_10')).not_to be_valid
    end
  end

  describe '#active' do
    it 'will only show versions that are active' do
      create_list(:pacbio_smrt_link_version, 5)
      create_list(:pacbio_smrt_link_version, 2, active: false)

      expect(described_class.active.count).to eq(5)
    end
  end

  describe '#ordered_by_default' do
    it 'will show the default version first' do
      create_list(:pacbio_smrt_link_version, 5)
      default_version = create(:pacbio_smrt_link_version, default: true)
      ordered_by_default = described_class.ordered_by_default
      expect(ordered_by_default.count).to eq(6)
      expect(ordered_by_default.first).to eq(default_version)
    end
  end
end
