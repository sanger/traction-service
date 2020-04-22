require 'rails_helper'

RSpec.describe Ont::Request, type: :model do
  it 'can have a container' do
    request = create(:ont_request)
    container_material = create(:container_material, material: request)
    expect(request.container).to eq(container_material.container)
  end
end
