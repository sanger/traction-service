FactoryBot.define do
  factory :pacbio_plate, class: Pacbio::Plate do
    run { create(:pacbio_run) }
  end
end