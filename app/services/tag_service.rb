# frozen_string_literal: true

# TagService
# The service will allow checking a collection of tags are unique
class TagService
  def initialize(tag_set)
    @tag_set = tag_set
    @tags = []
  end

  attr_reader :tag_set

  def find_and_register_tag(group_id)
    tag = Tag.find_by(tag_set_id: tag_set.id, group_id: group_id)
    tags << tag unless tag.nil?
    tag
  end

  def complete?
    tag_set.tags.count == tags.uniq.count
  end

  private

  attr_reader :tags
end
