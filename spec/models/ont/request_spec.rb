require 'rails_helper'

RSpec.describe Ont::Request, type: :model do
  it 'is not valid without a container' do
    expect(build(:ont_request, container: nil)).to_not be_valid
  end

  it 'is valid with a container' do
    container = create(:well)
    expect(create(:ont_request, container: container)).to be_valid
  end

  it 'has access to its container' do
    container = create(:well)
    expect(create(:ont_request, container: container).container).to eq container
  end

  it 'sets inverse relationship with container' do
    ont_request = create(:ont_request, container: create(:well))
    expect(ont_request.container.material).to eq(ont_request)
  end
end
