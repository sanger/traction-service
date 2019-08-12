FactoryBot.define do
  factory :pacbio_library, class: Pacbio::Library do
    volume { 1.111 }
    concentration { 2.222 }
    library_kit_barcode { 'LK1234567' }
    fragment_size { 100 }
  end
end
