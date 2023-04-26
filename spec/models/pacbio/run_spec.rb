# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::Run, pacbio: true do
  let!(:version10) { create(:pacbio_smrt_link_version, name: 'v10', default: true) }

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_run }

    it_behaves_like 'uuidable'
  end

  context 'validation' do
    it 'must have a sequencing kit box barcode' do
      expect(build(:pacbio_run, sequencing_kit_box_barcode: nil)).not_to be_valid
    end

    it 'must have a DNA control complex kit box barcode' do
      expect(build(:pacbio_run, dna_control_complex_box_barcode: nil)).not_to be_valid
    end

    it 'must have a system name' do
      expect(build(:pacbio_run, system_name: nil)).not_to be_valid
    end
  end

  context 'System Name' do
    it 'must include the correct options' do
      expect(described_class.system_names.keys).to eq(['Sequel II', 'Sequel I', 'Sequel IIe'])
    end

    it 'must have a System Name' do
      expect(create(:pacbio_run, system_name: 0).system_name).to eq 'Sequel II'
      expect(create(:pacbio_run, system_name: 'Sequel II').system_name).to eq 'Sequel II'
      expect(create(:pacbio_run, system_name: 1).system_name).to eq 'Sequel I'
      expect(create(:pacbio_run, system_name: 'Sequel I').system_name).to eq 'Sequel I'
      expect(create(:pacbio_run, system_name: 2).system_name).to eq 'Sequel IIe'
      expect(create(:pacbio_run, system_name: 'Sequel IIe').system_name).to eq 'Sequel IIe'
    end

    it 'must have a system_name default' do
      expect(create(:pacbio_run).system_name).to eq 'Sequel II'
    end
  end

  context 'associations' do
    it 'can have a plate' do
      plate = create(:pacbio_plate)
      run = create(:pacbio_run, plate:)
      expect(run.plate).to eq(plate)
    end

    it 'can have some wells' do
      wells = create_list(:pacbio_well, 5)
      plate = create(:pacbio_plate, wells:)
      run = create(:pacbio_run, plate:)
      expect(run.wells.count).to eq(5)
    end
  end

  describe '#comments' do
    it 'can have run comments' do
      run = create(:pacbio_run)
      expect(run.comments).to eq('A Run Comment')
    end

    it 'can have long run comments' do
      comments = 'X' * 65535
      run = create(:pacbio_run, comments:)
      run.reload
      expect(run.comments).to eq(comments)
    end

    it 'can have the wells summary when no run comments exist' do
      wells = create_list(:pacbio_well_with_pools, 2)
      plate = create(:pacbio_plate, wells:)
      run = create(:pacbio_run, plate:, comments: nil)
      expect(run.comments).to eq("#{wells.first.summary}:#{wells[1].summary}")
    end
  end

  describe '#generate_sample_sheet' do
    it 'must return a String' do
      well1 = create(:pacbio_well_with_pools)
      well2 = create(:pacbio_well_with_pools)

      plate = create(:pacbio_plate, wells: [well1, well2])
      run = create(:pacbio_run, plate:)

      sample_sheet = run.generate_sample_sheet
      expect(sample_sheet.class).to eq String
    end
  end

  context 'state' do
    it 'is pending by default' do
      run = create(:pacbio_run)
      expect(run).to be_pending
    end

    it 'can change the state to pending' do
      run = create(:pacbio_run)
      run.pending!
      expect(run).to be_pending
    end

    it 'can change the state to started' do
      run = create(:pacbio_run)
      run.started!
      expect(run).to be_started
    end

    it 'can change the state to completed' do
      run = create(:pacbio_run)
      run.completed!
      expect(run).to be_completed
    end

    it 'can change the state to cancelled' do
      run = create(:pacbio_run)
      run.cancelled!
      expect(run).to be_cancelled
    end

    it 'can filter runs based on state' do
      create_list(:pacbio_run, 2)
      create(:pacbio_run, state: :started)
      expect(described_class.pending.length).to eq 2
      expect(described_class.started.length).to eq 1
    end
  end

  context 'scope' do
    context 'active' do
      it 'returns only active runs' do
        create_list(:pacbio_run, 2)
        create(:pacbio_run, deactivated_at: DateTime.now)
        expect(described_class.active.length).to eq 2
      end
    end
  end

  context 'name' do
    it 'if left blank will populate automatically' do
      run = create(:pacbio_run, name: nil)
      expect(run.name).to be_present
      expect(run.name).to eq("#{Pacbio::Run::NAME_PREFIX}#{run.id}")
    end

    it 'if added should not be written over' do
      run = create(:pacbio_run, name: 'run1')
      expect(run.name).to eq('run1')
    end

    it 'must be unique' do
      run = create(:pacbio_run, name: 'run1')
      expect(build(:pacbio_run, name: run.name)).not_to be_valid
    end

    it 'is updateable' do
      run = create(:pacbio_run)
      run.update(name: 'run1')
      expect(run.name).to eq('run1')
    end
  end

  context 'smrt_link_version' do
    it 'will set a default value' do
      run = create(:pacbio_run)
      expect(run.smrt_link_version).to eq(version10)
    end
  end
end
