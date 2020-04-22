FactoryBot.define do
  factory :container do
    receptacle { create(:well) }
    material { create(:ont_request) }
  end
end
