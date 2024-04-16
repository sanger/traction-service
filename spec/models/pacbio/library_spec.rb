# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::Library, :pacbio do
  subject { build(:pacbio_library, params) }

  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v13_revio', default: true)
  end

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_library }

    it_behaves_like 'uuidable'
  end

  context 'when volume is nil' do
    let(:params) { { volume: nil } }

    it { is_expected.to be_valid }
  end

  context 'when volume is positive' do
    let(:params) { { volume: 23 } }

    it { is_expected.to be_valid }
  end

  context 'when volume is negative' do
    let(:params) { { volume: -23 } }

    it { is_expected.not_to be_valid }
  end

  context 'when volume is "a word"' do
    let(:params) { { volume: 'a word' } }

    it { is_expected.not_to be_valid }
  end

  context 'when concentration is nil' do
    let(:params) { { concentration: nil } }

    it { is_expected.to be_valid }
  end

  context 'when concentration is positive' do
    let(:params) { { concentration: 23 } }

    it { is_expected.to be_valid }
  end

  context 'when concentration is negative' do
    let(:params) { { concentration: -23 } }

    it { is_expected.not_to be_valid }
  end

  context 'when concentration is "a word"' do
    let(:params) { { concentration: 'a word' } }

    it { is_expected.not_to be_valid }
  end

  context 'when insert_size is nil' do
    let(:params) { { insert_size: nil } }

    it { is_expected.to be_valid }
  end

  context 'when insert_size is positive' do
    let(:params) { { insert_size: 23 } }

    it { is_expected.to be_valid }
  end

  context 'when insert_size is negative' do
    let(:params) { { insert_size: -23 } }

    it { is_expected.not_to be_valid }
  end

  context 'when insert_size is "a word"' do
    let(:params) { { insert_size: 'a word' } }

    it { is_expected.not_to be_valid }
  end

  context 'when primary_aliquot is nil' do
    let(:params) { { primary_aliquot: nil } }

    it { is_expected.not_to be_valid }
  end

  it 'can have a template prep kit box barcode' do
    expect(build(:pacbio_library, template_prep_kit_box_barcode: nil)).to be_valid
    expect(create(:pacbio_library).template_prep_kit_box_barcode).to be_present
  end

  it 'can have a request' do
    request = build(:pacbio_request)
    expect(build(:pacbio_library, request:).request).to eq(request)
  end

  it 'can have a tag' do
    tag = build(:tag)
    expect(build(:pacbio_library, tag:).tag).to eq(tag)
  end

  it 'can have a primary aliquot' do
    expect(create(:pacbio_library).primary_aliquot).to be_present
  end

  it 'can have derived aliquots' do
    library = create(:pacbio_library)
    aliquots = create_list(:aliquot, 5, aliquot_type: :derived, source: library)
    expect(library.derived_aliquots).to eq(aliquots)
  end

  it 'can have a used aliquot' do
    library = create(:pacbio_library)
    expect(library.used_aliquots.length).to eq(1)
    expect(library.used_aliquots.first.source).to eq(library.request)
  end

  describe 'destroy' do
    it 'gets destroyed if there are no associated wells and associated pools' do
      library = create(:pacbio_library)
      expect { library.destroy }.to change(described_class, :count).by(-1).and change(Aliquot, :count).by(-2)
    end

    it 'does not get destroyed if there are associated wells' do
      well = create(:pacbio_well)
      aliquot = create(:aliquot, used_by: well)
      library = create(:pacbio_library, derived_aliquots: [aliquot])
      expect { library.destroy }.not_to change(described_class, :count)
      # Check that the library has the expected error message
      expect(library.errors[:base]).to include('Cannot delete a library that is used in a pool or run')
    end

    it 'does not get destroyed if there are associated pools' do
      pool = build(:pacbio_pool)
      aliquot = create(:aliquot, used_by: pool)
      library = create(:pacbio_library, derived_aliquots: [aliquot])
      expect { library.destroy }.not_to change(described_class, :count)
      # Check that the library has the expected error message
      expect(library.errors[:base]).to include('Cannot delete a library that is used in a pool or run')
    end
  end

  describe '#sample_name' do
    it 'returns the sample name of the request' do
      request = create(:pacbio_request)
      expect(create(:pacbio_library, request:).sample_name).to eq(request.sample_name)
    end
  end

  describe '#cost_code' do
    it 'returns the cost code of the request' do
      request = create(:pacbio_request)
      expect(create(:pacbio_library, request:).cost_code).to eq(request.cost_code)
    end
  end

  describe '#external_study_id' do
    it 'returns the cost code of the request' do
      request = create(:pacbio_request)
      expect(create(:pacbio_library, request:).external_study_id).to eq(request.external_study_id)
    end
  end

  describe '#tube' do
    it 'can have a tube' do
      tube = create(:tube)
      expect(build(:pacbio_library, tube:).tube).to eq(tube)
    end

    it 'creates a tube by default if none are provided' do
      pacbio_library = create(:pacbio_library, tube: nil)
      expect(pacbio_library.tube).to be_present
    end
  end

  describe '#request' do
    let!(:library) { create(:pacbio_library, tag: create(:tag)) }

    it 'can have one' do
      expect(library.request).to be_present
    end

    it 'does not delete the requests when the library is deleted' do
      expect { library.destroy }.not_to change(Pacbio::Request, :count)
    end
  end

  context 'library' do
    let(:library_factory) { :pacbio_library }
    let(:library_model) { described_class }

    it_behaves_like 'library'
  end

  describe '#source_identifier' do
    let(:library) { create(:pacbio_library, :tagged) }

    context 'from a well' do
      before do
        create(:plate_with_wells_and_requests, pipeline: 'pacbio',
                                               row_count: 1, column_count: 1, barcode: 'BC12',
                                               requests: [library.request])
      end

      it 'returns the plate barcode and well' do
        expect(library.source_identifier).to eq('BC12:A1')
      end
    end

    context 'from a tube' do
      before do
        create(:tube_with_pacbio_request, pacbio_requests: [library.request], barcode: 'TRAC-2-757')
      end

      it 'returns the plate barcode and well' do
        expect(library.source_identifier).to eq('TRAC-2-757')
      end
    end
  end

  describe 'when volume is updated' do
    context 'when volume is updated to a value greater than used_volume' do
      it 'allows the update' do
        library = create(:pacbio_library, volume: 100)
        create_list(:aliquot, 5, aliquot_type: :derived, source: library, volume: 2)
        library.volume = 50
        allow(library).to receive(:check_volume).and_return(true)
        expect(library.save).to be_truthy
      end
    end

    context 'when volume is updated to a value less than used_volume' do
      let!(:library) { create(:pacbio_library, volume: 100) }

      before do
        create_list(:aliquot, 5, aliquot_type: :derived, source: library, volume: 2)
        library.volume = 5
      end

      it 'does not allow the update' do
        library.save
        expect(library.save).to be_falsey
      end

      it 'adds an error message' do
        library.save
        expect(library.errors[:volume]).to include('Volume must be greater than the current used volume')
      end
    end

    context 'when a field other than volume is updated' do
      it 'allows the update' do
        library = create(:pacbio_library, volume: 100)
        create_list(:aliquot, 5, aliquot_type: :derived, source: library, volume: 2)
        library.concentration = 50
        expect(library.save).to be_truthy
        expect(library.errors[:volume]).to be_empty
      end
    end
  end

  describe '#sequencing_plates' do
    it 'when there is no run' do
      library = create(:pacbio_library)
      expect(library.sequencing_plates).to be_empty
    end

    it 'when there is a single run' do
      plate = build(:pacbio_plate)
      library = create(:pacbio_library)
      plate.wells << create(:pacbio_well, libraries: [library])
      create(:pacbio_run, plates: [plate])
      expect(library.sequencing_plates).to eq([plate])
    end

    it 'when there are multiple runs' do
      plate1 = build(:pacbio_plate)
      plate2 = build(:pacbio_plate)
      create(:pacbio_run, plates: [plate1])
      create(:pacbio_run, plates: [plate2])
      library = create(:pacbio_library)
      plate1.wells << create(:pacbio_well, libraries: [library])
      plate2.wells << create(:pacbio_well, libraries: [library])
      expect(library.sequencing_plates).to eq([plate1, plate2])
    end
  end

  describe '#sequencing_runs' do
    it 'when there is no run' do
      library = create(:pacbio_library)
      expect(library.sequencing_runs).to be_empty
    end

    it 'when there is a single run' do
      plate = build(:pacbio_plate)
      library = create(:pacbio_library)
      plate.wells << create(:pacbio_well, libraries: [library])
      create(:pacbio_run, plates: [plate])
      expect(library.sequencing_runs).to eq([plate.run])
    end

    it 'when there are multiple runs' do
      plate1 = build(:pacbio_plate)
      plate2 = build(:pacbio_plate)
      create(:pacbio_run, plates: [plate1])
      create(:pacbio_run, plates: [plate2])
      library = create(:pacbio_library)
      plate1.wells << create(:pacbio_well, libraries: [library])
      plate2.wells << create(:pacbio_well, libraries: [library])
      expect(library.sequencing_runs).to eq([plate1.run, plate2.run])
    end
  end

  context 'wells' do
    it 'can have one or more' do
      library = create(:pacbio_library)
      create_list(:pacbio_well, 5, libraries: [library])
      expect(library.wells.count).to eq(5)
    end
  end
end
