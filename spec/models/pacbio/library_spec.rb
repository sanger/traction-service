require 'rails_helper'

RSpec.describe Pacbio::Library, type: :model, pacbio: true do

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_library }
    it_behaves_like 'uuidable'
  end

  it 'must have a volume' do
    expect(build(:pacbio_library, volume: nil)).to_not be_valid
  end

  it 'must have a concentration' do
    expect(build(:pacbio_library, concentration: nil)).to_not be_valid
  end

  it 'can have a template prep kit box barcode' do
    expect(build(:pacbio_library, template_prep_kit_box_barcode: nil)).to be_valid
    expect(create(:pacbio_library).template_prep_kit_box_barcode).to be_present
  end

  it 'must have a insert size' do
    expect(build(:pacbio_library, insert_size: nil)).to_not be_valid
  end

  it 'can have a request' do
    request = create(:pacbio_request)
    expect(build(:pacbio_library, request: request).request).to eq(request)
  end

  it 'can have a tag' do
    tag = create(:tag)
    expect(build(:pacbio_library, tag: tag).tag).to eq(tag)
  end

  it 'can have a pool' do
    pool = create(:pacbio_pool)
    expect(build(:pacbio_library, pool: pool).pool).to eq(pool)
  end

  it 'can have a tube through pool' do
    pool = create(:pacbio_pool)
    expect(build(:pacbio_library, pool: pool).tube).to eq(pool.tube)
  end

  describe '#request' do

    let!(:library) { create(:pacbio_library, tag: create(:tag)) }

    it 'can have one' do
      expect(library.request).to be_present
    end

    it 'will not delete the requests when the library is deleted' do
      expect { library.destroy }.not_to change(Pacbio::Request, :count)
    end
  end

  context 'library' do

    let(:library_factory) { :pacbio_library }
    let(:library_model) { Pacbio::Library }

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
      plate = create(:pacbio_plate_with_wells, :pooled)
      library = plate.wells.first.pools.first.libraries.first
      expect(library.sequencing_plates).to eq([plate])
    end

    it 'when there are multiple runs' do
      plate1 = create(:pacbio_plate)
      plate2 = create(:pacbio_plate)
      pool = create(:pacbio_pool)
      create(:pacbio_well, pools: [pool], plate: plate1)
      create(:pacbio_well, pools: [pool], plate: plate2)
      expect(pool.libraries.first.sequencing_plates).to eq([plate1, plate2])
    end
  end
end
