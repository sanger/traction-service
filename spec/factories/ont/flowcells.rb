# frozen_string_literal: true

# Examples:
# flowcell = build(:ont_flowcell, position: 2)
FactoryBot.define do
  factory :ont_flowcell, class: 'Ont::Flowcell' do
    position { 1 }
    sequence(:flowcell_id) { |n| "F#{n}" }
    pool { create(:ont_pool) }
    run { build(:ont_run, flowcells: [instance]) }
  end
end
