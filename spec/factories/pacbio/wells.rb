FactoryBot.define do
  factory :pacbio_well, class: Pacbio::Well do
    movie_time { 10 }
    sequence(:insert_size) { |n| "100#{n}"}
    sequence(:on_plate_loading_concentration) { |n| "10.#{n}"}
    row { 'A' }
    sequence(:column) { |n| "0#{n}"}
    plate { create(:pacbio_plate) }
    sequence(:comment) { |n| "comment#{n}" }
    generate_hifi { 'In SMRT Link' }
    ccs_analysis_output { '' }

    factory :pacbio_well_with_libraries do
      after(:create) do |well|
        well.libraries = create_list(:pacbio_library, 5)
      end
    end

    factory :pacbio_well_with_request_libraries do
      after(:create) do |well|
        well.libraries = create_list(:pacbio_library, 5)
      end
    end

    factory :pacbio_well_with_request_libraries_no_tag do
      after(:create) do |well|
        well.libraries = create_list(:pacbio_library, 5, tag: nil)
      end
    end
  end
end
