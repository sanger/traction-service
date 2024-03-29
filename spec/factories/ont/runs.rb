# frozen_string_literal: true

# Examples:
# run = build(:ont_run, flowcell_count: 3, flowcell_max: 5)
# run = build(:ont_gridion_run, flowcell_count: 3)
FactoryBot.define do
  factory :ont_run, class: 'Ont::Run' do
    transient do
      flowcell_count { 1 }
      flowcell_factory { :ont_flowcell }
      flowcell_max { 5 }
    end

    instrument { association :ont_instrument }
    state { 'pending' }

    flowcells do
      build_list(flowcell_factory, flowcell_count, run: instance) do |fc, idx|
        fc.position = (idx % flowcell_max) + 1
        fc.flowcell_id = format(Ont::Flowcell::FLOWCELL_ID_FORMAT, fc.position)
      end
    end

    factory :ont_minion_run do
      transient do
        flowcell_max { 1 }
      end
      instrument { association :ont_minion }
    end

    factory :ont_gridion_run do
      transient do
        flowcell_max { 5 }
      end
      instrument { association :ont_gridion }
    end

    factory :ont_promethion_run do
      transient do
        flowcell_max { 24 }
      end
      instrument { association :ont_promethion }
    end
  end
end
