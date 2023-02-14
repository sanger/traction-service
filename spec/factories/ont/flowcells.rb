# frozen_string_literal: true

# Examples:
# flowcell = build(:ont_flowcell, position: 2)
FactoryBot.define do
  factory :ont_flowcell, class: 'Ont::Flowcell' do
    position { 1 }
    flowcell_id { format(Ont::Flowcell::FLOWCELL_ID_FORMAT, Integer(position, exception: false) || 1) }
    pool { create(:ont_pool) }
    run { build(:ont_run, flowcells: [instance]) }
  end
end
