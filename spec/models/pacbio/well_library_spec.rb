require 'rails_helper'

RSpec.describe Pacbio::WellLibrary, type: :model, pacbio: true do

  it 'must have a well' do
    expect(build(:pacbio_well_library, well: nil)).to_not be_valid
  end

  it 'must have a library' do
    expect(build(:pacbio_well_library, library: nil)).to_not be_valid
  end

  it 'will have some library attributes' do
    request = create(:pacbio_request)
    library = create(:pacbio_library)
    create(:pacbio_request_library, request: request, library: library)
    library = create(:pacbio_well_library, library: library)
    
    expect(library.volume).to be_present
    expect(library.concentration).to be_present
    expect(library.library_kit_barcode).to be_present
    expect(library.fragment_size).to be_present
    expect(library.sample_names).to be_present
  end
  
end