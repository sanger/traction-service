FactoryBot.define do
  factory :pacbio_library, class: Pacbio::Library do
    volume { 1.111 }
    concentration { 2.222 }
    template_prep_kit_box_barcode { 'LK1234567' }
    fragment_size { 100 }
    request { create(:pacbio_request) }
    tag { create(:tag) }

    factory :pacbio_library_in_tube do
      after :create do |library|
        tube = create(:tube)
        create(:container_material, container: tube, material: library)
      end
    end
  end
end
