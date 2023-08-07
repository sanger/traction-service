# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::SmrtLinkOption, pacbio: true do
  describe '#create' do
    it 'is possible to create a new record' do
      expect { create(:pacbio_smrt_link_option) }.to change(described_class, :count).by(1)
    end

    it 'is possible to create multiple smrt link versions' do
      smrt_link_option = build(:pacbio_smrt_link_option)
      create_list(:pacbio_smrt_link_option_version, 3, smrt_link_option:)
      expect(smrt_link_option.smrt_link_versions.length).to eq(3)
    end

    it 'errors if missing required fields' do
      expect { described_class.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'validation' do
    it 'key must be unique' do
      option = create(:pacbio_smrt_link_option)
      expect(build(:pacbio_smrt_link_option, key: option.key)).not_to be_valid
    end

    it 'must have a valid data type' do
      expect { build(:pacbio_smrt_link_option, data_type: :wrong) }.to raise_error(ArgumentError)
    end

    it 'if data type is list then must have some select options' do
      expect(build(:pacbio_smrt_link_option, data_type: :list, select_options: 'a,b,c')).to be_valid
      expect(build(:pacbio_smrt_link_option, data_type: :list, select_options: nil)).not_to be_valid
    end
  end
end
