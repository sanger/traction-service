# frozen_string_literal: true

FactoryBot.define do
  factory :multi_pool_position do
    sequence(:position) { |n| "A#{n}" }

    # Associate to Pacbio Pool by default
    pool { association(:pacbio_pool) }
    # Associate at least one multi_pool_position to satisfy validation
    # mulit_pool_positions default to pacbio pools, can be overridden in tests
    multi_pool { association(:multi_pool) }
  end
end
