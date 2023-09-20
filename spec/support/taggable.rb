# frozen_string_literal: true

RSpec.shared_examples 'taggable' do
  it 'returns empty tags with no tag_taggables' do
    taggable = create(taggable_model, tags_count: 0)
    expect(taggable.tags).to be_empty
  end

  it 'returns all tags with many tag_taggables' do
    taggable = create(taggable_model)
    expect(taggable.tags).not_to be_empty
    expect(taggable.tags).to eq(taggable.tag_taggables.map(&:tag))
  end

  it 'on destroy destroys tag_taggables, not taggables' do
    num_tags = 3
    taggable = create(taggable_model, tags_count: num_tags)
    # sanity check
    expect(Tag.count).to eq(num_tags)
    # destroy the taggable
    taggable.destroy
    # test outcome
    expect(TagTaggable.count).to eq(0)
    expect(Tag.count).to eq(num_tags)
  end

  it 'returns expected sorted tags' do
    taggable = create(taggable_model, tags_count: 5)
    expected_tags = Tag.all.sort { |a, b| a.id <=> b.id }
    expect(taggable.sorted_tags).to match_array(expected_tags)
  end
end
