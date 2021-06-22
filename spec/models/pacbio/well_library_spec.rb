require 'rails_helper'

RSpec.describe Pacbio::WellLibrary, type: :model, pacbio: true do

  it 'must have a well' do
    expect(build(:pacbio_well_library, well: nil)).to_not be_valid
  end

  it 'must have a library' do
    expect(build(:pacbio_well_library, library: nil)).to_not be_valid
  end

  it 'can have a tube' do
    library = create(:pacbio_library_in_tube)
    well_library = create(:pacbio_well_library, library: library)
    expect(well_library.tube).to eq(library.tube)
    
  end

end
