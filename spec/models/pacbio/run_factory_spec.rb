# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::RunFactory do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v11', default: true)
  end

  describe '#construct_resources!' do
    subject(:construct_resources) do
      run_factory.construct_resources!
    end

    let(:run_factory) do
      build(:pacbio_run_factory, well_attributes:)
    end

    let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run)] }

    context 'create' do
      it 'creates a run' do
        expect { construct_resources }.to change(Pacbio::Run, :count).by(1)
      end
    end
  end
end
