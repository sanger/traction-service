FactoryBot.define do
  factory :container_material do
    container { create(:well) }
    material { create(:pacbio_request) }
  end
end
