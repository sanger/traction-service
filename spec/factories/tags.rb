FactoryBot.define do
  factory :tag do
    sequence(:oligo) { |n| ['A','C','G','T','A','C','G','T',n].shuffle[0,8].join }
    sequence(:group_id) {|n| n}
    set_name { 'pipeline1' }
  end
end
