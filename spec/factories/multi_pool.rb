# frozen_string_literal: true

FactoryBot.define do
  factory :multi_pool do
    pool_method { 0 } # enum for Plate
    pipeline { 1 } # enum for Pacbio

    # Associate at least one multi_pool_position to satisfy validation
    # mulit_pool_positions default to pacbio pools, can be overridden in tests
    multi_pool_positions { build_list(:multi_pool_position, 1, multi_pool: instance) }
  end
end
