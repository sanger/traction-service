require 'rails_helper'

RSpec.describe Well, type: :model do
  it 'must have plate' do
    expect(build(:well, plate: nil)).to_not be_valid
  end

  it 'must have a position' do
    expect(build(:well, position: nil)).to_not be_valid
  end

  it 'can have a material' do
    ont_request = create(:ont_request, container: build(:well))
    debugger
    # expect(ont_request.container.material).to eq ont_request
  end

end
