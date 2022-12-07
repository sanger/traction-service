# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Request do
  it 'must have a sample' do
    expect(build(:request, sample: nil)).not_to be_valid
  end

  it 'must have a requestable' do
    expect(build(:request, requestable: nil)).not_to be_valid
  end
end
