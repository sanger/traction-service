FactoryBot.define do
  factory :tag do
    sequence(:oligo) { |n| ['A','C','G','T','A','C','G','T',n].shuffle[0,8].join }
    sequence(:group_id) { |n| n }
    tag_set_id { TagSet.find_or_create_by(name: 'Test Tag Set', uuid: '123456').id }
  end
end
