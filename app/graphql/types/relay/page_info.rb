# frozen_string_literal: true

module Types
  module Relay
    # The return type of a connection's `pageInfo` field
    class PageInfo < GraphQL::Types::Relay::BaseObject
      default_relay true
      description 'Information about pagination in a connection.'

      field :has_next_page, Boolean,
            method: :next_page?, null: false,
            description: 'When paginating forwards, are there more items?'

      field :has_previous_page, Boolean,
            method: :previous_page?, null: false,
            description: 'When paginating backwards, are there more items?'

      field :page_count, Integer,
            null: false, description: 'The number of pages available at the current page size.'

      field :entities_count, Integer,
            null: false, description: 'The total number of entities.'
    end
  end
end
