FactoryBot.define do
  factory :tag_taggable do
    tag { create(:tag) }
    taggable { create(:ont_request) }
  end
end
