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
    tube = create(:tube)
    create(:container_material, container: tube, material: library)
    well_library = create(:pacbio_well_library, library: library)

    expect(well_library.barcode).to be_present
  end

end
