FactoryBot.define do
  factory :tube do

    factory :tube_with_saphyr_request do
      material { create(:saphyr_request) }
    end

    factory :tube_with_saphyr_library do
      material { create(:saphyr_library) }
    end

    factory :tube_with_pacbio_library do
      material { create(:pacbio_library) }
    end

    factory :tube_with_pacbio_request do
      material { create(:pacbio_request) }
    end
  end

end
