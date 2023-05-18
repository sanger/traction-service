# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::RunFactory do
  let!(:smrt_link_version) do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v11', default: true)
  end

  describe '#construct_resources!' do
    subject(:construct_resources) do
      run_factory.construct_resources!
    end

    let(:run_attributes) { attributes_for(:pacbio_run).merge(pacbio_smrt_link_version_id: smrt_link_version.id) }

    let(:run_factory) do
      build(:pacbio_run_factory, run_attributes:, well_attributes:)
    end

    let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run)] }

    context 'create' do
      it 'creates a run' do
        # p well_attributes
        expect { construct_resources }.to change(Pacbio::Run, :count).by(1)
      end
    end
  end

  describe 'create a new run thats invalid' do
    subject(:run_factory) { build(:pacbio_run_factory, run_attributes:, well_attributes:) }

    let(:run_attributes)  { attributes_for(:pacbio_run).merge(pacbio_smrt_link_version_id: smrt_link_version.id, sequencing_kit_box_barcode: nil) }
    let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run)] }

    it 'not valid' do
      run_factory.construct_resources!
      expect(run_factory).not_to be_valid
    end
  end
end
