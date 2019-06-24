FactoryBot.define do
  factory :pacbio_tag, class: Pacbio::Tag do
    oligo { 'ATGC' }
  end
end