# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagSet do
  it 'is valid with all params' do
    expect(build(:tag_set, name: 'Test Tag Set Custom', uuid: '11111')).to be_valid
  end

  it 'is not valid without a name' do
    expect(build(:tag_set, name: nil)).not_to be_valid
  end

  it 'is not valid without a pipeline' do
    expect(build(:tag_set, pipeline: nil)).not_to be_valid
  end

  it 'can contain tags' do
    set = create(:tag_set)
    expect(set.tags.count).to eq 0

    tag = create(:tag)
    set.tags << tag
    expect(set.tags.count).to eq 1
  end
end
