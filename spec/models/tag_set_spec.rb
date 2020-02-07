require "rails_helper"

RSpec.describe TagSet, type: :model do

  it 'is valid with all params' do
    expect(create(:tag_set, name: "Test Tag Set Custom", uuid: "11111")).to be_valid
  end

  it 'is not valid without a name' do
    expect(build(:tag_set, name: nil)).to_not be_valid
  end

  it 'can contain tags' do
    set = create(:tag_set)
    expect(set.tags.count).to eq 0

    tag = create(:tag)
    set.tags << tag
    expect(set.tags.count).to eq 1
  end
end
