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
  
end