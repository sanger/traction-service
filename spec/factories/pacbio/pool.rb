FactoryBot.define do
  factory :pacbio_pool, class: Pacbio::Pool do
    tube { create(:tube) }
    libraries { create_list(:pacbio_library, 1, pool: instance)}
  end
end
