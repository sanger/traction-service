# frozen_string_literal: true

module Types
  module Connections
    # A connection definition to paginate plates with.
    class PaginatedConnectionWrapper < GraphQL::Pagination::Connection
      attr_reader :page_num, :page_size, :total_item_count

      def initialize(items, page_num:, page_size:, total_item_count:, max_page_size: :not_given)
        super(items, max_page_size: max_page_size)

        @total_item_count = total_item_count
        @page_size = clamp_integer(page_size, min_value: 0)
        @page_num = clamp_integer(page_num, min_value: 1, max_value: [page_count, 1].max)
      end

      def nodes
        @items.offset(start_item_index).limit(page_size).order(updated_at: :desc)
      end

      def cursor_for(item)
        encode(item.id.to_s)
      end

      def next_page?
        end_item_index < total_item_count
      end

      def previous_page?
        page_num > 1
      end

      def page_count
        (total_item_count.to_f / page_size).ceil
      end

      def current_page
        page_num
      end

      def entities_count
        total_item_count
      end

      private

      def clamp_integer(value, min_value: nil, max_value: nil)
        return value if value.nil?

        clamped_value = value.round
        clamped_value = [clamped_value, min_value].max unless min_value.nil?
        clamped_value = [clamped_value, max_value].min unless max_value.nil?

        clamped_value.to_i
      end

      def start_item_index
        (page_num - 1) * page_size
      end

      def end_item_index
        start_item_index + nodes.count
      end
    end
  end
end
