FactoryBot.define do
  factory :pacbio_request_library, class: Pacbio::Request do
    library   { create(:pacbio_library) }

    factory :pacbio_request_library_with_tag do
      tagged
    end

    trait :tagged do
      tag
    end
  end
end
