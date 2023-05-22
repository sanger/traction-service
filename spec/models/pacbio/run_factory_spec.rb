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

    let(:run_factory) do
      build(:pacbio_run_factory, run_attributes:, well_attributes:)
    end

    let!(:pool) { create(:pacbio_pool) }
    let(:run_attributes) { attributes_for(:pacbio_run).merge(pacbio_smrt_link_version_id: smrt_link_version.id) }
    let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run).merge(pools: [pool.id]).with_indifferent_access] }

    context 'create' do
      it 'creates a run' do
        expect { construct_resources }.to change(Pacbio::Run, :count).by(1)
      end

      it 'creates a plate' do
        expect { construct_resources }.to change(Pacbio::Plate, :count).by(1)
      end

      it 'creates a well' do
        expect { construct_resources }.to change(Pacbio::Well, :count).by(1)
      end

      it 'attaches a pool to the well' do
        construct_resources
        expect(Pacbio::Well.first.pools.first).to eq(pool)
      end
    end
  end

  describe 'with invalid run' do
    subject(:run_factory) { build(:pacbio_run_factory, run_attributes:, well_attributes:) }

    let(:run_attributes)  { attributes_for(:pacbio_run).merge(pacbio_smrt_link_version_id: smrt_link_version.id, sequencing_kit_box_barcode: nil) }
    let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run)] }

    it { is_expected.to be_invalid }
  end

  describe.skip 'with invalid well' do
    subject(:run_factory) { build(:pacbio_run_factory, run_attributes:, well_attributes:) }

    let(:run_attributes)  { attributes_for(:pacbio_run).merge(pacbio_smrt_link_version_id: smrt_link_version.id) }
    let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run).merge(row: nil)] }

    it { is_expected.to be_invalid }
  end
end
