require "rails_helper"

RSpec.describe Tag, type: :model do

  it 'is valid with all params' do
    expect(create(:tag, oligo: "CGATCGAATAT", group_id: "1", set_name: 'set name')).to be_valid
  end

  it 'is not valid without an oligo' do
    expect(build(:tag, oligo: nil)).to_not be_valid
  end

  it 'is not valid without a group id' do
    expect(build(:tag, group_id: nil)).to_not be_valid
  end

  it 'group id should be unique within set' do
    tag = create(:tag)
    expect(build(:tag, group_id: tag.group_id)).to_not be_valid
  end

  it 'is not valid without a set name' do
    expect(build(:tag, set_name: nil)).to_not be_valid
  end

  it 'oligo should be unique within set' do
    tag = create(:tag)
    expect(build(:tag, oligo: tag.oligo)).to_not be_valid
  end
end
