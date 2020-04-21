require 'rails_helper'

RSpec.describe Ont::Request, type: :model do
  it 'must have a container' do
    expect(build(:ont_request, container: nil)).to_not be_valid
  end
end
