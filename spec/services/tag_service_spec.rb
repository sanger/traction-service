require 'rails_helper'

RSpec.describe TagService do
  let!(:tag1) { create(:tag) }
  let!(:tag2) { create(:tag) }

  it 'returns nil when fetching tag with no matching group id' do
    tag_service = TagService.new(tag1.tag_set)
    tag = tag_service.find_and_register_tag('invalid group id')
    expect(tag).to be_nil
  end

  it 'returns existing tag' do
    tag_service = TagService.new(tag1.tag_set)
    tag = tag_service.find_and_register_tag(tag1.group_id)
    expect(tag).to eq(tag1)
  end

  it 'is not complete without registering all tags in a set' do
    tag_service = TagService.new(tag1.tag_set)
    tag_service.find_and_register_tag(tag1.group_id)
    expect(tag_service.complete?).to be_falsey
  end

  it 'is not complete having registered a tag more than once' do
    tag_service = TagService.new(tag1.tag_set)
    tag_service.find_and_register_tag(tag1.group_id)
    tag_service.find_and_register_tag(tag1.group_id)
    expect(tag_service.complete?).to be_falsey
  end

  it 'is complete with all tags in a set registered' do
    tag_service = TagService.new(tag1.tag_set)
    tag_service.find_and_register_tag(tag1.group_id)
    tag_service.find_and_register_tag(tag2.group_id)
    expect(tag_service.complete?).to be_truthy
  end
end
