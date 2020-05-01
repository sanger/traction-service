FactoryBot.define do
  factory :pacbio_library, class: Pacbio::Library do
    volume { 1.111 }
    concentration { 2.222 }
    library_kit_barcode { 'LK1234567' }
    fragment_size { 100 }

    factory :pacbio_library_in_tube do
      after :create do |library|
        tube = create(:tube)
        create(:container_material, container: tube, material: library)
      end
    end
  end
end
