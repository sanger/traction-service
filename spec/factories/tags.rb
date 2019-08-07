FactoryBot.define do
  factory :tag do
    sequence(:oligo) { |n| ['A','C','G','T','A','C','G','T',n].shuffle[0,8].join }
    group_id { 1 }
    set_name { 'pipeline1' }
  end
end
