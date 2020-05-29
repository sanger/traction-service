# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagSetService, type: :model do
  let(:tag_set) { create(:tag_set_with_tags) }

  it 'is initialised with no loaded tag sets' do
    tag_set_service = TagSetService.new
    expect(tag_set_service.loaded_tag_sets).to be_empty
  end

  it 'does not load tag set if it does not exist' do
    tag_set_service = TagSetService.new
    tag_set_service.load_tag_set('does not exist')
    expect(tag_set_service.loaded_tag_sets).to be_empty
  end

  it 'has expected tag_ids_by_oligo if tag set exists' do
    tag_set_service = TagSetService.new
    tag_set_service.load_tag_set(tag_set.name)
    tag_set.tags.each do |tag|
      expect(tag_set_service.loaded_tag_sets[tag_set.name][tag.oligo]).to eq(tag.id)
    end
  end
end
