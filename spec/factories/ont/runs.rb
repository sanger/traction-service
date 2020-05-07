FactoryBot.define do
  factory :ont_run, class: Ont::Run do
    instrument_name { 'GridION' }

    after(:create) do |run|
      run.flowcells = [
        create(:ont_flowcell, position: 2, run: run),
        create(:ont_flowcell, position: 4, run: run)
      ]
    end
  end
end
