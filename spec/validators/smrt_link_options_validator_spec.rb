# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmrtLinkOptionsValidator do
  describe '#validate' do
    let(:record) { build(:pacbio_well) }
    let(:available_smrt_link_versions)  { SmrtLink::Versions::AVAILABLE }
    let(:required_fields_by_version) { SmrtLink::Versions.required_fields_by_version }

    let(:versions) { create_list(:pacbio_smrt_link_version, 2)}

    before do
      described_class.new(available_smrt_link_versions: ,required_fields_by_version:).validate(record)
    end

    context 'valid' do

      it 'does not add an error to the record' do
        expect(record).to be_valid
      end
    end

  end
end
