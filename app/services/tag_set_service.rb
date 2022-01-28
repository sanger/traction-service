# frozen_string_literal: true

# TagSetService
# A service for fetching whole tag sets into memory
class TagSetService
  attr_reader :loaded_tag_sets

  def initialize
    @loaded_tag_sets = {}
  end

  def load_tag_set(tag_set_name)
    return if loaded_tag_sets.key?(tag_set_name)

    tag_set = TagSet.find_by(name: tag_set_name)

    return if tag_set.nil?

    loaded_tag_sets[tag_set_name] = tag_set.tags.to_h { |tag| [tag.oligo, tag.id] }
  end
end
