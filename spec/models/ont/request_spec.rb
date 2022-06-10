# frozen_string_literal: true

require 'rails_helper'
require './spec/support/read_only'

RSpec.describe Ont::Request, type: :model, ont: true do
  before do
    set_read_only(described_class, false)
  end

  context 'material' do
    let(:material_model) { :ont_request }

    it_behaves_like 'material'
  end
end
