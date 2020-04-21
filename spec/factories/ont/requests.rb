FactoryBot.define do
  factory :ont_request, class: 'Ont::Request' do
    container { create(:well) }
  end
end
