# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::Run, :pacbio do
  let!(:version10) { create(:pacbio_smrt_link_version, name: 'v10') }
  let!(:version12_sequel_iie) { create(:pacbio_smrt_link_version, name: 'v12_sequel_iie') }
  let!(:version12_revio) { create(:pacbio_smrt_link_version, name: 'v12_revio') }
  let!(:version13_revio) { create(:pacbio_smrt_link_version, name: 'v13_revio', default: true) }

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_revio_run }

    it_behaves_like 'uuidable'
  end

  context 'validation' do
    context 'v10 and v11' do
      it 'can have a DNA control complex kit box barcode' do
        expect(build(:pacbio_sequel_run, smrt_link_version: version10, dna_control_complex_box_barcode: 'DCCB1234')).to be_valid
      end
    end

    context 'v12_sequel_iie' do
      it 'must have a DNA control complex kit box barcode' do
        expect(build(:pacbio_sequel_run, smrt_link_version: version12_sequel_iie, dna_control_complex_box_barcode: nil)).not_to be_valid
      end
    end

    it 'must have a system name' do
      expect(build(:pacbio_sequel_run, system_name: nil)).not_to be_valid
    end

    context 'when system name is Revio' do
      it 'does not need a DNA control complex barcode' do
        expect(build(:pacbio_revio_run, dna_control_complex_box_barcode: nil)).to be_valid
      end

      it 'must have the wells in the correct positions' do
        plate_1 = build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])
        plate_2 = build(:pacbio_plate, wells: [build(:pacbio_well, row: 'G', column: '12')])
        expect(build(:pacbio_revio_run, plates: [plate_1, plate_2])).not_to be_valid
      end
    end
  end

  context 'System Name' do
    it 'must include the correct options' do
      expect(described_class.system_names.keys).to eq(['Sequel II', 'Sequel I', 'Sequel IIe', 'Revio'])
    end

    it 'must have a System Name' do
      expect(create(:pacbio_generic_run, system_name: 0).system_name).to eq 'Sequel II'
      expect(create(:pacbio_generic_run, system_name: 'Sequel II').system_name).to eq 'Sequel II'
      expect(create(:pacbio_generic_run, system_name: 1).system_name).to eq 'Sequel I'
      expect(create(:pacbio_generic_run, system_name: 'Sequel I').system_name).to eq 'Sequel I'
      expect(create(:pacbio_sequel_run, system_name: 2).system_name).to eq 'Sequel IIe'
      expect(create(:pacbio_sequel_run, system_name: 'Sequel IIe').system_name).to eq 'Sequel IIe'
      expect(create(:pacbio_revio_run, system_name: 3).system_name).to eq 'Revio'
      expect(create(:pacbio_revio_run, system_name: 'Revio').system_name).to eq 'Revio'
    end
  end

  it 'must have a system_name default' do
    expect(create(:pacbio_sequel_run).system_name).to eq 'Sequel IIe'
  end

  context 'associations' do
    it 'can have multiple plates for Revio' do
      plates = build_list(:pacbio_plate, 2, wells: [build(:pacbio_well, row: 'A', column: '1')])
      run = create(:pacbio_generic_run, system_name: 'Revio', plates:)
      expect(run.plates).to eq(plates)
      expect(run.wells.count).to eq(2)
    end

    it 'can have some wells' do
      plates = [build(:pacbio_plate, wells: build_list(:pacbio_well, 5))]
      run = create(:pacbio_generic_run, plates:)
      expect(run.wells.count).to eq(5)
    end
  end

  describe '#comments' do
    it 'can have run comments' do
      run = create(:pacbio_sequel_run)

      comment = run.wells.collect do |well|
        concentration = well.library_concentration || well.on_plate_loading_concentration
        " #{well.used_aliquots.first.source.tube.barcode} #{concentration}pM"
      end.join(' ')
      expect(run.comments).to eq("A Run Comment#{comment}")
    end

    it 'can have the wells summary when no run comments exist' do
      wells = create_list(:pacbio_well, 2)
      plate = build(:pacbio_plate, wells:)
      run = create(:pacbio_generic_run, plates: [plate], comments: nil)

      comment = run.wells.collect do |well|
        concentration = well.library_concentration || well.on_plate_loading_concentration
        " #{well.used_aliquots.first.source.tube.barcode} #{concentration}pM"
      end.join(' ')
      expect(run.comments).to eq(comment)
    end
  end

  describe '#generate_sample_sheet' do
    it 'must return a String' do
      well1 = build(:pacbio_well)
      well2 = build(:pacbio_well)

      plate = build(:pacbio_plate, wells: [well1, well2])
      run = create(:pacbio_generic_run, plates: [plate])

      sample_sheet = run.generate_sample_sheet
      expect(sample_sheet.is_a?(String)).to be(true)
    end

    shared_examples 'generates sample sheet with' do |desired_sample_sheet_class|
      let(:run) { create(:pacbio_revio_run, smrt_link_version:) }

      it 'calls payload on the correct sample sheet class' do
        sample_sheet_instance = instance_double(desired_sample_sheet_class, payload: 'sample_sheet')
        allow(desired_sample_sheet_class).to receive(:new).and_return(sample_sheet_instance)

        run.generate_sample_sheet

        expect(desired_sample_sheet_class).to have_received(:new) # rubocop:disable RSpec/MessageSpies
        expect(sample_sheet_instance).to have_received(:payload) # rubocop:disable RSpec/MessageSpies
      end
    end

    context 'with a v12_revio run' do
      let(:smrt_link_version) { version12_revio }

      it_behaves_like 'generates sample sheet with', RunCsv::PacbioSampleSheet
    end

    context 'with a v13_revio run' do
      let(:smrt_link_version) { version13_revio }

      it_behaves_like 'generates sample sheet with', RunCsv::PacbioSampleSheetV1
    end
  end

  context 'state' do
    it 'is pending by default' do
      run = create(:pacbio_revio_run)
      expect(run).to be_pending
    end

    it 'can change the state to pending' do
      run = create(:pacbio_revio_run)
      run.pending!
      expect(run).to be_pending
    end

    it 'can change the state to started' do
      run = create(:pacbio_revio_run)
      run.started!
      expect(run).to be_started
    end

    it 'can change the state to completed' do
      run = create(:pacbio_revio_run)
      run.completed!
      expect(run).to be_completed
    end

    it 'can change the state to cancelled' do
      run = create(:pacbio_revio_run)
      run.cancelled!
      expect(run).to be_cancelled
    end

    it 'can filter runs based on state' do
      create_list(:pacbio_revio_run, 2)
      create(:pacbio_revio_run, state: :started)
      expect(described_class.pending.length).to eq 2
      expect(described_class.started.length).to eq 1
    end
  end

  context 'scope' do
    context 'active' do
      it 'returns only active runs' do
        create_list(:pacbio_revio_run, 2)
        create(:pacbio_revio_run, deactivated_at: DateTime.now)
        expect(described_class.active.length).to eq 2
      end
    end
  end

  context 'name' do
    it 'if left blank will populate automatically' do
      run = create(:pacbio_revio_run, name: nil)
      expect(run.name).to be_present
      expect(run.name).to eq("#{Pacbio::Run::NAME_PREFIX}#{run.id}")
    end

    it 'if added should not be written over' do
      wells = create_list(:pacbio_well, 2)
      plate = build(:pacbio_plate, wells:)
      run = create(:pacbio_generic_run, name: 'run1', plates: [plate])
      expect(run.name).to eq('run1')
    end

    it 'must be unique' do
      wells = create_list(:pacbio_well, 2)
      plate = build(:pacbio_plate, wells:)
      run = create(:pacbio_generic_run, name: 'run1', plates: [plate])
      expect(build(:pacbio_generic_run, name: run.name)).not_to be_valid
    end

    it 'is updateable' do
      run = create(:pacbio_revio_run)
      run.update(name: 'run1')
      expect(run.name).to eq('run1')
    end
  end

  context 'smrt_link_version' do
    it 'sets a default value' do
      run = create(:pacbio_revio_run)
      expect(run.smrt_link_version).to eq(version13_revio)
    end
  end

  context 'instrument name' do
    it 'sets a default value' do
      run = create(:pacbio_revio_run)
      expect(run.instrument_name).to eq(run.system_name)
    end
  end

  describe '#create with nested attributes' do
    let!(:pools) { create_list(:pacbio_pool, 2) }

    it 'creates a run' do
      wells_attributes = [build(:pacbio_well, row: 'A', column: '1').attributes.merge(used_aliquots_attributes: [{
                                                                                        source_id: pools[0].id, source_type: 'Pacbio::Pool', volume: 10, concentration: 20, aliquot_type: :derived, template_prep_kit_box_barcode: '033000000000000000000'
                                                                                      }, { source_id: pools[1].id, source_type: 'Pacbio::Pool', volume: 10, concentration: 20, aliquot_type: :derived, template_prep_kit_box_barcode: '033000000000000000000' }])]
      expect { create(:pacbio_generic_run, plates_attributes: [{ wells_attributes:, sequencing_kit_box_barcode: 'DM0001100861800123121', plate_number: 1 }]) }.to change(described_class, :count).by(1)
    end

    it 'removes existing wells' do
      plates = [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')])]
      run = create(:pacbio_revio_run, plates:)
      expect { run.update(plates_attributes: { id: run.plates.first.id, sequencing_kit_box_barcode: 'DM0001100861800123121', plate_number: 1, wells_attributes: [{ id: run.plates.first.wells.first.id, _destroy: true }] }) }.to change(run.plates.first.wells, :count).by(-1)
    end

    it 'removes existing wells and readds the with the same position' do
      plates = [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])]
      run = create(:pacbio_revio_run, plates:)
      run.update(plates_attributes: { id: run.plates.first.id, sequencing_kit_box_barcode: 'DM0001100861800123121', plate_number: 1, wells_attributes: [{ id: run.plates.first.wells.first.id, _destroy: true }, build(:pacbio_well, row: 'A', column: '1').attributes.merge({ used_aliquots_attributes: [{ source_id: pools[0].id, source_type: 'Pacbio::Pool', volume: 10, concentration: 20, aliquot_type: :derived, template_prep_kit_box_barcode: '033000000000000000000' }] })] })
      run.reload
      expect(run.plates.first.wells.count).to eq(1)
      expect(run.plates.first.wells.first.position).to eq('A1')
    end

    it 'updates the run with the new attributes' do
      plates = [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])]
      run = create(:pacbio_revio_run, plates:)
      run.update(state: 'started')
      run.reload
      expect(run.state).to eq('started')
      expect(run.plates.first.wells.first.position).to eq('A1')
    end
  end

  describe 'validate number of plates' do
    it 'when system name is Sequel IIe' do
      expect(build(:pacbio_sequel_run)).to be_valid
      expect(build(:pacbio_generic_run, system_name: 'Sequel IIe', plates: [build(:pacbio_plate), build(:pacbio_plate)])).not_to be_valid
    end

    it 'when system name is Revio' do
      expect(build(:pacbio_revio_run)).to be_valid
      expect(build(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])).to be_valid
      expect(build(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])])).not_to be_valid
    end
  end

  describe 'update smrt link options' do
    it 'updates the smrt link otpions' do
      run = create(:pacbio_revio_run)
      run.update_smrt_link_options(library_type: nil)
      run.reload
      expect(run.wells.first.library_type).to be_nil
      expect(run.wells.last.library_type).to be_nil
      expect(run.update_smrt_link_options(library_type: 'Standard')).to eq 3
      run.reload
      expect(run.wells.first.library_type).to eq 'Standard'
      expect(run.wells.last.library_type).to eq 'Standard'
    end
  end

  describe 'aliquots_to_publish_on_run' do
    it 'returns all the aliquots used for a run of source type eq to library or pool' do
      request = build(:pacbio_request)
      pool_library = create(:pacbio_library)
      pool1 = create(:pacbio_pool, used_aliquots: [create(:aliquot, source: request, aliquot_type: :derived)])
      pool2 = create(:pacbio_pool, used_aliquots: [create(:aliquot, source: pool_library, aliquot_type: :derived)])
      run_library = create(:pacbio_library)
      wells = [build(:pacbio_well, row: 'A', column: '1', libraries: [run_library]),
               build(:pacbio_well, row: 'B', column: '1', pools: [pool1, pool2])]
      run = create(:pacbio_revio_run, plates: [build(:pacbio_plate, wells:)])
      run.aliquots_to_publish_on_run do |aliquot|
        expect(aliquot.source_type).to eq('Pacbio::Library').or eq('Pacbio::Pool')
      end
    end

    it 'includes used_aliquots coming from pool with type source eq to pool' do
      request_pool = create(:pacbio_pool, used_aliquots: [create(:aliquot, source: build(:pacbio_request), aliquot_type: :derived)])
      library_pool = create(:pacbio_pool, used_aliquots: [create(:aliquot, source: build(:pacbio_library), aliquot_type: :derived)])
      wells = [build(:pacbio_well, row: 'A', column: '1', libraries: [create(:pacbio_library)]),
               build(:pacbio_well, row: 'B', column: '1', pools: [request_pool, library_pool])]
      run = create(:pacbio_revio_run, plates: [build(:pacbio_plate, wells:)])

      library_pool.used_aliquots do |aliquot|
        expect(run.aliquots_to_publish_on_run).to include(aliquot)
      end

      request_pool.used_aliquots do |aliquot|
        expect(run.aliquots_to_publish_on_run).not_to include(aliquot)
      end
    end

    it 'includes used_aliquots coming from library in a pool in the run and from the library directly added to run' do
      pool_library = create(:pacbio_library)
      pool = create(:pacbio_pool, used_aliquots: [create(:aliquot, source: pool_library, aliquot_type: :derived)])
      run_library = create(:pacbio_library)
      wells = [build(:pacbio_well, row: 'A', column: '1', libraries: [run_library]),
               build(:pacbio_well, row: 'B', column: '1', pools: [pool])]
      run = create(:pacbio_revio_run, plates: [build(:pacbio_plate, wells:)])
      library_aliquot_used_in_run = wells.flat_map(&:used_aliquots).find { |aliquot| aliquot.source_type == 'Pacbio::Library' && aliquot.source_id == run_library.id }
      library_aliquot_from_pool = pool.used_aliquots.find { |aliquot| aliquot.source_type == 'Pacbio::Library' && aliquot.source_id == pool_library.id }
      expect(run.aliquots_to_publish_on_run).to include(library_aliquot_used_in_run, library_aliquot_from_pool)
    end
  end
end
