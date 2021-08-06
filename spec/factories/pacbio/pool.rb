FactoryBot.define do
  factory :pacbio_pool, class: Pacbio::Pool do
    transient do
      library_count { 1 }
    end

   # tube { build(:tube) }
    libraries { build_list(:pacbio_library, library_count, pool: instance) }
    template_prep_kit_box_barcode { 'ABC1' }
    concentration { 10 }
    volume { 10 }
    fragment_size { 100 }
  end
end
