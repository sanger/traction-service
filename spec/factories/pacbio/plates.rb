FactoryBot.define do
  factory :pacbio_plate, class: Pacbio::Plate do
    sequence(:barcode) {|n| "PACBIO-#{n}"}
    run { create(:pacbio_run) }
  end
end