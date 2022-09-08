# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::SmrtLinkOption, type: :model, pacbio: true do
  describe '#create' do
    it 'is possible to create a new record' do
      expect { create(:pacbio_smrt_link_option) }.to change(described_class, :count).by(1)
    end

    it 'is possible to create multiple smrt link versions' do
      smrt_link_option = create(:pacbio_smrt_link_option, count: 3)
      expect(smrt_link_option.smrt_link_versions.length).to eq(3)
    end

    it 'errors if missing required fields' do
      expect { described_class.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  # describe 'validation' do

  #   it 'name must be unique' do
  #     version = create(:pacbio_smrt_link_version)
  #     expect(build(:pacbio_smrt_link_version, name: version.name)).not_to be_valid
  #   end

  #   it 'name must be formatted correctly' do
  #     expect(build(:pacbio_smrt_link_version, name: 'v1.1')).not_to be_valid
  #   end
  # end
end
