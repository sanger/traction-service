FactoryBot.define do
  factory :tag_taggable do
    tag { create(:tag) }
    taggable { create(:pacbio_request) }
  end
end
