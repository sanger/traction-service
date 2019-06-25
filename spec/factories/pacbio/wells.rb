FactoryBot.define do
  factory :pacbio_well, class: Pacbio::Well do
    sequencing_mode { 0 }
    movie_time { 10 }
    insert_size { 1000 }
    on_plate_loading_concentration { 10.35 }
    row { 'A' }
    column { '01' }
    plate { create(:pacbio_plate) }
  end
end