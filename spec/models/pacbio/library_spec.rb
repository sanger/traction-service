require 'rails_helper'

RSpec.describe Pacbio::Library, type: :model, pacbio: true do

  it 'must have a volume' do
    expect(build(:pacbio_library, volume: nil)).to_not be_valid
  end

  it 'must have a concentration' do
    expect(build(:pacbio_library, concentration: nil)).to_not be_valid
  end

  it 'must have a library kit barcode' do
    expect(build(:pacbio_library, library_kit_barcode: nil)).to_not be_valid
  end

  it 'must have a fragment size' do
    expect(build(:pacbio_library, fragment_size: nil)).to_not be_valid
  end

  it 'will have a uuid' do
    expect(create(:pacbio_library).uuid).to be_present
  end

  it 'can have sample names' do
    expect(create(:pacbio_library).sample_names).to be_truthy
  end

  it 'can have a barcode through tube delegation' do
    library = create(:pacbio_library)
    tube_with_library = create(:tube, material: library)
    expect(library.barcode).to eq tube_with_library.barcode
  end

  context 'wells' do
    it 'can have one or more' do
      library = create(:pacbio_library)
      library.wells << create_list(:pacbio_well, 5)
      expect(library.wells.count).to eq(5)
    end
  end

  context 'requests' do

    let!(:library) { create(:pacbio_library)}

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
    let(:library_model) { Pacbio::Library}

    it_behaves_like 'library'
  end

end