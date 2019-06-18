FactoryBot.define do
  factory :flowcell do
    chip
    position { 1 }

    factory :flowcell_with_library do
      library
    end
  end
end
