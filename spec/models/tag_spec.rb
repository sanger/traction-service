require "rails_helper"

RSpec.describe Tag, type: :model do

  it 'is valid with all params' do
    expect(create(:tag, oligo: "CGATCGAATAT", group_id: "1")).to be_valid
  end

  it 'is not valid without an oligo' do
    expect(build(:tag, oligo: nil)).to_not be_valid
  end

  it 'is not valid without a group id' do
    expect(build(:tag, group_id: nil)).to_not be_valid
  end

  it 'is not valid without a set name' do
    expect(build(:tag, tag_set_id: nil)).to_not be_valid
  end

  it 'delegates set name to tag set' do
    tag = build(:tag)
    expect(tag.tag_set_name).to eq(tag.tag_set.name)
  end

  it 'group id should be unique within set' do
    tag = create(:tag)
    expect(build(:tag, group_id: tag.group_id)).to_not be_valid
  end

  it 'oligo should be unique within set' do
    tag = create(:tag)
    expect(build(:tag, oligo: tag.oligo)).to_not be_valid
  end

  it 'returns empty taggables with no tag_taggables' do
    tag = create(:tag_with_taggables, taggables_count: 0)
    expect(tag.taggables).to be_empty
  end

  it 'returns all taggables from many tag_taggables' do
    tag = create(:tag_with_taggables)
    expect(tag.taggables).to_not be_empty
    expect(tag.taggables).to eq(tag.tag_taggables.map { |tag_taggable| tag_taggable.taggable })
  end

  it 'on destroy destroys tag taggables, not taggables' do
    tag = create(:tag_with_taggables)
    numTaggables = tag.taggables.count
    # sanity check
    expect(numTaggables).to eq(3)
    expect(Ont::Request.all.count).to eq(numTaggables)
    # destroy the tag
    tag.destroy
    # test outcome
    expect(TagTaggable.all.count).to eq(0)
    expect(Ont::Request.all.count).to eq(numTaggables)
  end
end
