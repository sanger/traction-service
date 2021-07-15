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

  it 'must have a template prep kit box barcode' do
    expect(build(:pacbio_library, template_prep_kit_box_barcode: nil)).to_not be_valid
  end

  it 'must have a fragment size' do
    expect(build(:pacbio_library, fragment_size: nil)).to_not be_valid
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

  it 'can have a tube' do
    library = create(:pacbio_library)
    tube = create(:tube)
    create(:container_material, container: tube, material: library)
    expect(library.tube).to eq tube
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

  context 'tube material' do
    let(:material_model) { :pacbio_library }
    it_behaves_like "tube_material"
  end

  describe '#source_identifier' do
    let(:library) { create(:pacbio_library, :tagged) }

    before do
      create(:plate_with_wells_and_requests, pipeline: 'pacbio',
             row_count: 1, column_count: 1, barcode: 'BC12',
             requests: [library.request])
    end

    it 'returns the plate barcode and well' do
      expect(library.source_identifier).to eq('BC12:A1')
    end
  end
end
