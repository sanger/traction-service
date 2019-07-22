FactoryBot.define do
  factory :pacbio_tag, class: Pacbio::Tag do
    oligo { 'ATGC' }
    group_id { 1 }
  end
end