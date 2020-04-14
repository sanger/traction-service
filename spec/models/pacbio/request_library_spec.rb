require 'rails_helper'

RSpec.describe Pacbio::RequestLibrary, type: :model, pacbio: true do

  it 'must have a request' do
    expect(build(:pacbio_request_library, request: nil)).to_not be_valid
  end

  it 'must have a library' do
    expect(build(:pacbio_request_library, library: nil)).to_not be_valid
  end

  it 'can have a tag' do
    expect(build(:pacbio_request_library, tag: create(:tag)).tag).to be_present
  end

  it 'can have a sample name' do
    expect(create(:pacbio_request_library).sample_name).to be_present
  end

  it 'can have some tag attributes' do
    request_library = create(:pacbio_request_library, tag: create(:tag))
    expect(request_library.tag_oligo).to be_present
    expect(request_library.tag_group_id).to be_present
    expect(request_library.tag.tag_set.name).to be_present
    expect(request_library.tag_id).to be_present
  end

  describe 'validation' do
    it 'tags must be unique within the context of a library' do
      library = create(:pacbio_library)
      tag = create(:tag)
            request = create(:pacbio_request)


      create(:pacbio_request_library, request: request, library: library, tag: tag)
      expect(build(:pacbio_request_library, request: request, library: library, tag: tag)).to be_valid
    end

    it 'requests must be unique within the context of a library and a tag' do
      library = create(:pacbio_library)
      tag1 = create(:tag)
      tag2 = create(:tag)
      request = create(:pacbio_request)
      
      create(:pacbio_request_library, request: request, library: library, tag: tag1)
      expect(build(:pacbio_request_library, request: request, library: library, tag: tag1)).to be_valid
    end
  end

end