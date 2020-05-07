FactoryBot.define do
  factory :ont_flowcell, class: Ont::Flowcell do
    position { 2 }
    run { create(:ont_run) }
    library { create(:ont_library) }
  end
end
