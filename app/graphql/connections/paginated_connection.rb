# frozen_string_literal: true

module Connections
  # A connection definition to paginate plates with.
  class PaginatedConnection < GraphQL::Pagination::Connection
    attr_accessor :page_num
    attr_accessor :page_size
    attr_accessor :entity_count

    def nodes
      @items.offset(start_item_index).limit(page_size).order(updated_at: :desc)
    end

    def cursor_for(item)
      encode(item.id.to_s)
    end

    def start_item_index
      (page_num - 1) * page_size
    end

    def end_item_index
      start_item_index + nodes.count
    end

    # rubocop:disable Naming/PredicateName
    # Justification: We don't get a choice in these names -- they're part of the GraphQL-Ruby
    def has_next_page
      end_item_index < entity_count
    end

    def has_previous_page
      page_num > 1
    end
    # rubocop:enable Naming/PredicateName
  end
end
