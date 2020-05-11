FactoryBot.define do
  factory :ont_library_request, class: Ont::LibraryRequest do
    library { create(:ont_library) }
    request { create(:ont_request) }
    tag { create(:tag) }
  end
end
