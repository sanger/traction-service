FactoryBot.define do
  factory :container_material do
    container { create(:well) }
    material { create(:ont_request) }
  end
end
