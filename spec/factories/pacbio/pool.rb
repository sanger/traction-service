FactoryBot.define do
  factory :pacbio_pool, class: Pacbio::Pool do
    tube { build(:tube) }
    libraries { build_list(:pacbio_library, 1, pool: instance) }
    template_prep_kit_box_barcode { 'ABC1' }
    concentration { 10 }
    volume { 10 }
    fragment_size { 100 }
  end
end
