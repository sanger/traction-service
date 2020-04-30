RSpec.shared_examples "taggable" do
  it 'returns empty tags with no tag_taggables' do
    taggable = create(taggable_model, tags_count: 0)
    expect(taggable.tags).to be_empty
  end

  it 'returns all tags with many tag_taggables' do
    taggable = create(taggable_model)
    expect(taggable.tags).to_not be_empty
    expect(taggable.tags).to eq(taggable.tag_taggables.map { |tag_taggable| tag_taggable.tag })
  end

  it 'on destroy destroys tag_taggables, not taggables' do
    numTags = 3
    taggable = create(taggable_model, tags_count: numTags)
    # sanity check
    expect(Tag.all.count).to eq(numTags)
    # destroy the taggable
    taggable.destroy
    # test outcome
    expect(TagTaggable.all.count).to eq(0)
    expect(Tag.all.count).to eq(numTags)
  end
end
