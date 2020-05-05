# frozen_string_literal: true

# TagService
# The service will allow checking a collection of tags are unique
class TagService
  def initialize(tag_set)
    @all_tags = tag_set.nil? ? [] : Tag.where(tag_set_id: tag_set.id)
    @registered_tags = Set.new
  end

  def find_and_register_tag(group_id)
    found_tag = all_tags.find { |tag| tag.group_id == group_id }
    registered_tags << found_tag unless found_tag.nil?
    found_tag
  end

  def complete?
    all_tags.count == registered_tags.count
  end

  private

  attr_reader :all_tags, :registered_tags
end
