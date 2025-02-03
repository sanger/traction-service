# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NullTagSet do
  let(:null_tag_set) { described_class.new }

  it 'returns false for default_sample_sheet_behaviour?' do
    expect(null_tag_set.default_sample_sheet_behaviour?).to be(false)
  end

  it 'returns false for hidden_sample_sheet_behaviour?' do
    expect(null_tag_set.hidden_sample_sheet_behaviour?).to be(false)
  end

  it 'returns nil for uuid' do
    expect(null_tag_set.uuid).to be_nil
  end
end
