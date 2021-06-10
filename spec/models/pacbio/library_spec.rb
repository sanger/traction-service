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

  it 'can have sample names' do
    expect(create(:pacbio_library).sample_names).to be_truthy
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

  it 'can have a barcode through tube delegation' do
    library = create(:pacbio_library)
    tube = create(:tube)
    create(:container_material, container: tube, material: library)
    expect(library.barcode).to eq tube.barcode
  end

  context 'wells' do
    it 'can have one or more' do
      library = create(:pacbio_library)
      library.wells << create_list(:pacbio_well, 5)
      expect(library.wells.count).to eq(5)
    end
  end

  context 'requests' do

    let!(:library) { create(:pacbio_library) }

    before(:each) do
      (1..5).each do |i|
        create(:pacbio_request_library, request: create(:pacbio_request), library: library, tag: create(:tag))
      end
    end

    it 'can have one or more' do
      expect(library.requests.count).to eq(5)
    end

    it 'will have some sample names' do
      sample_names = library.sample_names.split(',')
      expect(sample_names.length).to eq(5)
      expect(sample_names.any?(&:blank?)).to be_falsey
    end

    it 'will delete the library requests when the library is deleted' do
      expect { library.destroy }.to change(Pacbio::RequestLibrary, :count).by(-5)
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
    let(:library) { create(:pacbio_library) }
    let(:requests) do
      create_list(:pacbio_request_library, 5, :tagged, library: library).map(&:request)
    end

    before do
      create(:plate_with_wells_and_requests, pipeline: 'pacbio',
             row_count: 5, column_count: 1, barcode: 'BC12',
             requests: requests)
    end

    it 'returns the plate barcode and wells' do
      expect(library.source_identifier).to eq('BC12:A1-E1')
    end
  end
end
