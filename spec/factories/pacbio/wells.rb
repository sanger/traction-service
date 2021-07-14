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

    transient do
      library_count { 5 }
    end

    factory :pacbio_well_with_libraries do
      after(:create) do |well, evaluator|
        well.libraries = create_list(:pacbio_library, evaluator.library_count)
      end
    end

    factory :pacbio_well_with_libraries_and_pools do
      after(:create) do |well, evaluator|
        well.libraries = create_list(:pacbio_library, evaluator.library_count)
        well.pools = create_list(:pacbio_pool, evaluator.library_count)
      end
    end

    factory :pacbio_well_with_libraries_in_tubes_and_pools do
      after(:create) do |well, evaluator|
        well.libraries = create_list(:pacbio_library_in_tube, evaluator.library_count)
        well.pools = create_list(:pacbio_pool, evaluator.library_count)
      end
    end

    factory :pacbio_well_with_libraries_untagged do
      after(:create) do |well, evaluator|
        well.libraries = create_list(:pacbio_library, evaluator.library_count, :untagged)
      end
    end
  end

end
