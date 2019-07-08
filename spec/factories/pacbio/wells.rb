FactoryBot.define do
  factory :pacbio_well, class: Pacbio::Well do
    movie_time { 10 }
    sequence(:insert_size) { |n| "100#{n}"}
    sequence(:on_plate_loading_concentration) { |n| "10.#{n}"}
    row { 'A' }
    sequence(:column) { |n| "0#{n}"}
    plate { create(:pacbio_plate) }
    sequence(:comment) { |n| "comment#{n}" }

    factory :pacbio_well_with_library do
      library { create(:pacbio_library) }
    end
  end
end
