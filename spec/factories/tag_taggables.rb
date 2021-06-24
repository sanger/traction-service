FactoryBot.define do
  factory :tag_taggable do
    tag { create(:ont_tag) }
    taggable { create(:ont_request) }
  end
end
