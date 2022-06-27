# frozen_string_literal: true

FactoryBot.define do
  factory :ont_flowcell, class: 'Ont::Flowcell' do
    position { 3 }
    run { create(:ont_run) }
    library { create(:ont_library) }
  end
end
