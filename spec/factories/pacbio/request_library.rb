FactoryBot.define do
  factory :pacbio_request_library, class: Pacbio::RequestLibrary do
    request   { create(:pacbio_request) }
    library   { create(:pacbio_library) }

    factory :pacbio_request_library_with_tag do
      tag { create(:tag) }
    end
  end
end
