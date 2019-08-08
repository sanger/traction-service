require 'rails_helper'

RSpec.describe Pacbio::RequestLibrary, type: :model, pacbio: true do

  it 'must have a request' do
    expect(build(:pacbio_request_library, request: nil)).to_not be_valid
  end

  it 'must have a library' do
    expect(build(:pacbio_request_library, library: nil)).to_not be_valid
  end

  it 'must have a tag' do
    expect(build(:pacbio_request_library, tag: nil)).to_not be_valid
  end

  it 'can have a sample name' do
    expect(create(:pacbio_request_library).sample_name).to be_present
  end

  it 'can have some tag attributes' do
    request_library = create(:pacbio_request_library)
    expect(request_library.tag_oligo).to be_present
    expect(request_library.tag_group_id).to be_present
    expect(request_library.tag_set_name).to be_present
    expect(request_library.tag_id).to be_present
  end

  it 'tags must be unique within the context of a library' do
    library = create(:pacbio_library)
    tag = create(:tag)

    create(:pacbio_request_library, request: create(:pacbio_request), library: library, tag: tag)
    expect(build(:pacbio_request_library, request: create(:pacbio_request), library: library, tag: tag)).to_not be_valid
  end
  
end