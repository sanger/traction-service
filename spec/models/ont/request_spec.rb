require 'rails_helper'

RSpec.describe Ont::Request, type: :model do
  it 'can have a container' do
    request = create(:request)
    container = create(:container, material: request)
    expect(container.material).to eq(request)
  end
end
