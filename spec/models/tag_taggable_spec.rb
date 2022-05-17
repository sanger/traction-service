require 'rails_helper'

RSpec.describe TagTaggable, type: :model do
  it 'is not valid without a tag' do
    expect(build(:tag_taggable, tag: nil)).to_not be_valid
  end

  it 'is not valid without a taggable' do
    expect(build(:tag_taggable, taggable: nil)).to_not be_valid
  end
end
