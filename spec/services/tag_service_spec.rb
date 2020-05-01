require 'rails_helper'

RSpec.describe TagService do
  context 'with nil tag set' do
    it 'returns nil when fetching a tag' do
      tag_service = TagService.new(nil)
      tag = tag_service.find_and_register_tag('tag group id')
      expect(tag).to be_nil
    end

    it 'is complete' do
      tag_service = TagService.new(nil)
      expect(tag_service.complete?).to be_truthy
    end
  end

  context 'with tag set' do
    let!(:tag_set) { create(:tag_set_with_tags, number_of_tags: 2)}

    it 'returns nil when fetching tag with no matching group id' do
      tag_service = TagService.new(tag_set)
      tag = tag_service.find_and_register_tag('invalid group id')
      expect(tag).to be_nil
    end
  
    it 'returns existing tag' do
      tag_service = TagService.new(tag_set)
      tag = tag_service.find_and_register_tag(tag_set.tags.first.group_id)
      expect(tag).to eq(tag_set.tags.first)
    end
  
    it 'is not complete without registering all tags in a set' do
      tag_service = TagService.new(tag_set)
      tag_service.find_and_register_tag(tag_set.tags.first.group_id)
      expect(tag_service.complete?).to be_falsey
    end
  
    it 'is not complete having registered a tag more than once' do
      tag_service = TagService.new(tag_set)
      tag_service.find_and_register_tag(tag_set.tags.first.group_id)
      tag_service.find_and_register_tag(tag_set.tags.first.group_id)
      expect(tag_service.complete?).to be_falsey
    end
  
    it 'is complete with all tags in a set registered' do
      tag_service = TagService.new(tag_set)
      tag_service.find_and_register_tag(tag_set.tags.first.group_id)
      tag_service.find_and_register_tag(tag_set.tags.second.group_id)
      expect(tag_service.complete?).to be_truthy
    end
  end
end
