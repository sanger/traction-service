# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::RunFactory do
  let!(:version10) { create(:pacbio_smrt_link_version, name: 'v10', default: true) }
  let!(:pacbio_run) { create(:pacbio_run, smrt_link_version: version10) }
  let!(:run_factory) do
    build(:pacbio_run_factory, wells_attributes:, pacbio_run:)
  end

  describe '#attr_accessor' do
    let!(:wells_attributes) { [] }

    it 'has a run and wells_attributes' do
      expect(run_factory.pacbio_run).to eq pacbio_run
      expect(run_factory.wells_attributes).to eq wells_attributes
    end
  end

  describe '#construct_resources!' do
    subject(:construct_resources) do
      run_factory.construct_resources!
    end

    let!(:pool1) { create(:pacbio_pool) }
    let!(:pool2) { create(:pacbio_pool) }

    let!(:well_attributes1) { attributes_for(:pacbio_well, plate: nil) }
    let!(:well_attributes2) { attributes_for(:pacbio_well, plate: nil) }

    let(:wells_attributes) do
      [
        well_attributes1.merge({ pools: [{ id: pool1.id }] }),
        well_attributes2.merge({ pools: [{ id: pool2.id }] })
      ]
    end

    it 'creates 1 plate' do
      expect { construct_resources }.to change(Pacbio::Plate, :count).by(1)
    end

    it 'creates 2 wells' do
      expect { construct_resources }.to change(Pacbio::Well, :count).by(2)
    end

    it 'creates 2 well pools' do
      expect { construct_resources }.to change(Pacbio::WellPool, :count).by(2)
    end

    it 'associates the wells and pools with the run' do
      construct_resources
      expect(pacbio_run.plate.wells.count).to eq 2
      expect(pacbio_run.plate.wells[0].pools).to eq [pool1]
      expect(pacbio_run.plate.wells[1].pools).to eq [pool2]
    end
  end

  describe '#update_resources!' do
    subject(:update_resources) do
      run_factory.update_resources!
    end

    context 'when run has one well, and we update that well' do
      let!(:well1) { create(:pacbio_well_with_pools, pool_count: 1) }
      let!(:pacbio_run) { create(:pacbio_run, smrt_link_version: version10, plate: well1.plate) }

      let(:wells_attributes) do
        attrs = well1.attributes
        attrs['row'] = 'H'
        attrs['column'] = '12'

        return [
          attrs.merge({ pools: [{ id: well1.pools[0].id }] }).with_indifferent_access
        ]
      end

      it 'does not create a plate' do
        expect { update_resources }.not_to change(Pacbio::Plate, :count)
      end

      it 'does not create a well' do
        expect { update_resources }.not_to change(Pacbio::Well, :count)
      end

      it 'does not create a well pool' do
        expect { update_resources }.not_to change(Pacbio::WellPool, :count)
      end

      it 'updates the well' do
        update_resources
        pacbio_run.reload
        expect(pacbio_run.plate.wells.count).to eq 1
        expect(pacbio_run.plate.wells[0].row).to eq 'H'
        expect(pacbio_run.plate.wells[0].column).to eq '12'
        expect(pacbio_run.plate.wells[0].pools).to eq [well1.pools[0]]
      end
    end

    context 'when run has one well, and we add a new well' do
      let!(:well1) { create(:pacbio_well_with_pools, pool_count: 1) }
      let!(:well_attributes2) { attributes_for(:pacbio_well, plate: nil) }

      let!(:pacbio_run) { create(:pacbio_run, smrt_link_version: version10, plate: well1.plate) }

      let!(:pool2) { create(:pacbio_pool) }

      let(:wells_attributes) do
        return [
          well1.attributes.merge({ pools: [{ id: well1.pools[0].id }] }),
          well_attributes2.merge({ pools: [{ id: pool2.id }] })
        ]
      end

      it 'does not create a plate' do
        expect { update_resources }.not_to change(Pacbio::Plate, :count)
      end

      it 'does create a well' do
        expect { update_resources }.to change(Pacbio::Well, :count).by(1)
      end

      it 'does create a well pool' do
        expect { update_resources }.to change(Pacbio::WellPool, :count).by(1)
      end

      it 'updates the well' do
        update_resources
        pacbio_run.reload
        expect(pacbio_run.plate.wells.count).to eq 2
        expect(pacbio_run.plate.wells[0]).to eq well1
        expect(pacbio_run.plate.wells[1].pools).to eq [pool2]
      end
    end

    context 'when run has one well, and we remove that well' do
      let!(:well1) { create(:pacbio_well_with_pools, pool_count: 1) }
      let(:well_attributes2) { attributes_for(:pacbio_well, plate: nil) }

      let!(:pacbio_run) { create(:pacbio_run, smrt_link_version: version10, plate: well1.plate) }

      let(:pool2) { create(:pacbio_pool) }

      let(:wells_attributes) do
        return []
      end

      it 'does not create a plate' do
        expect { update_resources }.not_to change(Pacbio::Plate, :count)
      end

      it 'does create a well' do
        expect { update_resources }.to change(Pacbio::Well, :count).by(-1)
      end

      it 'does create a well pool' do
        expect { update_resources }.to change(Pacbio::WellPool, :count).by(-1)
      end

      it 'updates the well' do
        update_resources
        pacbio_run.reload
        expect(pacbio_run.plate.wells.count).to eq 0
      end
    end

    context 'when run has two wells, and we update one well, add a new well, and remove a well' do
      # Remove well1
      let!(:well1) { create(:pacbio_well_with_pools, pool_count: 1) }

      # Update well2
      let!(:well2) { create(:pacbio_well_with_pools, pool_count: 1, plate: well1.plate) }

      # Create well3
      let!(:well_attributes3) { attributes_for(:pacbio_well, plate: nil) }

      let!(:pacbio_run) { create(:pacbio_run, smrt_link_version: version10, plate: well1.plate) }

      let!(:pool3) { create(:pacbio_pool) }

      let(:wells_attributes) do
        well2_attributes = well2.attributes
        well2_attributes['row'] = 'H'
        well2_attributes['column'] = '12'

        return [
          well2_attributes.merge({ pools: [{ id: well2.pools[0].id }] }),
          well_attributes3.merge({ pools: [{ id: pool3.id }] })
        ]
      end

      it 'does not create a plate' do
        expect { update_resources }.not_to change(Pacbio::Plate, :count)
      end

      it 'creates one well, and destroys one well' do
        # +1 -1 = 0
        expect { update_resources }.not_to change(Pacbio::Well, :count)
      end

      it 'creates one well pool, and destroys one well pool' do
        # +1 -1 = 0
        expect { update_resources }.not_to change(Pacbio::WellPool, :count)
      end

      it 'updates the well' do
        update_resources
        pacbio_run.reload
        expect(pacbio_run.plate.wells.count).to eq 2
        expect(pacbio_run.plate.wells[0]).to eq well2
        expect(pacbio_run.plate.wells[1].pools).to eq [pool3]
      end
    end

    context 'when run has one well, and we update the wells pool' do
      let!(:well1) { create(:pacbio_well_with_pools, pool_count: 1) }

      let!(:pacbio_run) { create(:pacbio_run, smrt_link_version: version10, plate: well1.plate) }

      let!(:pool2) { create(:pacbio_pool) }

      let(:wells_attributes) do
        return [
          well1.attributes.merge({ pools: [{ id: pool2.id }] })
        ]
      end

      it 'does not create a plate' do
        expect { update_resources }.not_to change(Pacbio::Plate, :count)
      end

      it 'does create a well' do
        expect { update_resources }.not_to change(Pacbio::Well, :count)
      end

      it 'does create a well pool' do
        # Removes the old well pool, and creates a new one
        # +1 -1 = 0
        expect { update_resources }.not_to change(Pacbio::WellPool, :count)
      end

      it 'updates the well' do
        update_resources
        pacbio_run.reload
        expect(pacbio_run.plate.wells.count).to eq 1
        expect(pacbio_run.plate.wells[0]).to eq well1
        expect(pacbio_run.plate.wells[0].pools).to eq [pool2]
      end
    end
  end
end
