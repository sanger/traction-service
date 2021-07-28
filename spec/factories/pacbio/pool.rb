FactoryBot.define do
  factory :pacbio_pool, class: Pacbio::Pool do
    tube { build(:tube) }
    libraries { build_list(:pacbio_library, 1, pool: instance) }
  end
end
