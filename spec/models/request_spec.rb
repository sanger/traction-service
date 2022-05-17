# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Request, type: :model do

  it 'must have a sample' do
    expect(build(:request, sample: nil)).to_not be_valid
  end

  it 'must have a requestable' do
    expect(build(:request, requestable: nil)).to_not be_valid
  end

end
