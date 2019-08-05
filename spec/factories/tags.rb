FactoryBot.define do
  factory :tag do
    oligo { ['A','C','G','T','A','C','G','T'].shuffle[0,8].join }
    group_id { 1 }
    set_name { 'pipeline1' }
  end
end
