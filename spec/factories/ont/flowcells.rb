# frozen_string_literal: true

FactoryBot.define do
  factory :ont_flowcell, class: 'Ont::Flowcell' do
    position { 3 }
    run { create(:ont_run) }
    # We have changed it to use pool rather than library.
    # library { create(:ont_library) }
    pool { create(:ont_pool) }
  end
end
