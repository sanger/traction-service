# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::Library, :pacbio do
  subject { build(:pacbio_library, params) }

  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
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

  it 'can have a pool' do
    pool = build(:pacbio_pool)
    expect(build(:pacbio_library, pool:).pool).to eq(pool)
  end

  it 'can have a primary aliquot' do
    library = create(:pacbio_library)
    aliquot = create(:aliquot, aliquot_type: :primary, source: library)
    expect(library.primary_aliquot).to eq(aliquot)
  end

  it 'can have derived aliquots' do
    library = create(:pacbio_library)
    aliquots = create_list(:aliquot, 5, aliquot_type: :derived, source: library)
    expect(library.derived_aliquots).to eq(aliquots)
  end

  it 'can have a tube' do
    tube = create(:tube)
    expect(build(:pacbio_library, tube:).tube).to eq(tube)
  end

  it 'can have a tube through pool' do
    pool = create(:pacbio_pool)
    expect(create(:pacbio_library, pool:).pool.tube).to eq(pool.tube)
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
        create(:tube_with_pacbio_request, requests: [library.request], barcode: 'TRAC-2-757')
      end

      it 'returns the plate barcode and well' do
        expect(library.source_identifier).to eq('TRAC-2-757')
      end
    end
  end

  describe '#sequencing_plates' do
    it 'when there is no run' do
      library = create(:pacbio_library)
      expect(library.sequencing_plates).to be_empty
    end

    it 'when there is a single run' do
      plate = build(:pacbio_plate_with_wells, :pooled)
      create(:pacbio_run, plates: [plate])
      library = plate.wells.first.pools.first.libraries.first
      expect(library.sequencing_plates).to eq([plate])
    end

    it 'when there are multiple runs' do
      plate1 = build(:pacbio_plate)
      plate2 = build(:pacbio_plate)
      create(:pacbio_run, plates: [plate1])
      create(:pacbio_run, plates: [plate2])
      pool = create(:pacbio_pool)
      create(:pacbio_well, pools: [pool], plate: plate1)
      create(:pacbio_well, pools: [pool], plate: plate2)
      expect(pool.libraries.first.sequencing_plates).to eq([plate1, plate2])
    end
  end
end
