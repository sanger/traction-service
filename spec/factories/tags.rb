FactoryBot.define do
  factory :tag do
    sequence(:oligo) { |n| ['A','C','G','T','A','C','G','T',n].shuffle[0,8].join }
    sequence(:group_id) { |n| n }
    tag_set_id { TagSet.find_or_create_by(name: 'Test Tag Set', uuid: '123456').id }

    factory :tag_with_taggables do   
      transient do
        taggables_count { 3 }
      end   

      after(:create) do |tag, evaluator|
        create_list(:tag_taggable, evaluator.taggables_count, tag: tag)
      end
    end
  end
end
