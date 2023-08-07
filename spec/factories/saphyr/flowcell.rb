# frozen_string_literal: true

FactoryBot.define do
  factory :saphyr_flowcell, class: 'Saphyr::Flowcell' do
    chip { association :saphyr_chip }

    position { 1 }

    factory :saphyr_flowcell_with_library do
      library { association :saphyr_library }
    end

    factory :saphyr_flowcell_with_library_in_tube do
      library { association :saphyr_library_in_tube }
    end
  end
end
