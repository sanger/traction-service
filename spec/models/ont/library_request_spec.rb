require 'rails_helper'

RSpec.describe Ont::LibraryRequest, type: :model do
  it 'is not valid without a library' do
    expect(build(:ont_library_request, library: nil)).to_not be_valid
  end

  it 'is not valid without a request' do
    expect(build(:ont_library_request, request: nil)).to_not be_valid
  end

  it 'is not valid without a tag_taggable' do
    expect(build(:ont_library_request, tag: nil)).to_not be_valid
  end
end
