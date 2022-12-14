# frozen_string_literal: true

FactoryBot.define do
  factory :ont_run, class: 'Ont::Run' do
    instrument { create(:ont_instrument) }
    factory :ont_run_with_flowcells do
      after(:create) do |run|
        run.flowcells = [
          create(:ont_flowcell, position: 2, run:),
          create(:ont_flowcell, position: 4, run:)
        ]
      end
    end
  end
end
