require "rails_helper"

RSpec.describe Tag, type: :model do

  it 'is not valid without an oligo' do
    expect(build(:tag, oligo: nil)).to_not be_valid
  end

  it 'is not valud without a group id' do
    expect(build(:tag, group_id: nil)).to_not be_valid
  end

  it 'is not valid without a set name' do
    expect(build(:tag, set_name: nil)).to_not be_valid
  end

  it 'oligo should be unique within set' do
    tag = create(:tag)
    expect(build(:tag, oligo: tag.oligo, set_name: 'another set')).to be_valid
    expect(build(:tag, oligo: tag.oligo, set_name: tag.set_name)).to_not be_valid
  end
end
