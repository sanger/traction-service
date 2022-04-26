# frozen_string_literal: true

require 'rails_helper'
require './spec/support/read_only.rb'

RSpec.describe Ont::Request, type: :model, ont: true do

  before(:all) do
    set_read_only(Ont::Request, false)
  end

  after(:all) do
    set_read_only(Ont::Request, true)
  end

  context 'material' do
    let(:material_model) { :ont_request }
    it_behaves_like 'material'
  end

  context 'taggable' do
    let(:taggable_model) { :ont_request_with_tags }
    it_behaves_like 'taggable'
  end

  it 'must have a name' do
    request = build(:ont_request, name: nil)
    expect(request).not_to be_valid
  end

  it 'must have an external_id' do
    request = build(:ont_request, external_id: nil)
    expect(request).not_to be_valid
  end

end
