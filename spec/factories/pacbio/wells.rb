FactoryBot.define do
  factory :pacbio_well, class: Pacbio::Well do
    movie_time { 10 }
    sequence(:insert_size) { |n| "100#{n}"}
    sequence(:on_plate_loading_concentration) { |n| "10.#{n}"}
    row { 'A' }
    sequence(:column) { |n| "0#{n}"}
    plate { create(:pacbio_plate) }
    sequence(:comment) { |n| "comment#{n}" }
    sequencing_mode { 0 }

    factory :pacbio_well_with_libraries do
      after(:create) do |well|
        well.libraries = create_list(:pacbio_library, 5)
      end
    end
  end
end
