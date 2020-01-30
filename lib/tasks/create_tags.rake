# frozen_string_literal: true

namespace :tags do
  task create: :environment do
    Tag.create!(oligo: 'CACATATCAGAGTGCGT', group_id: 'bc1001_BAK8A_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'ACACACAGACTGTGAGT', group_id: 'bc1002_BAK8A_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'ACACATCTCGTGAGAGT', group_id: 'bc1003_BAK8A_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'ACAGTCGAGCGCTGCGT', group_id: 'bc1008_BAK8A_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'ACACACGCGAGACAGAT', group_id: 'bc1009_BAK8A_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'ACGCGCTATCTCAGAGT', group_id: 'bc1010_BAK8A_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'CTATACGTATATCTATT', group_id: 'bc1011_BAK8A_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'ACACTAGATCGCGTGTT', group_id: 'bc1012_BAK8A_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'CGCATGACACGTGTGTT', group_id: 'bc1015_BAK8B_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'CATAGAGAGATAGTATT', group_id: 'bc1016_BAK8B_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'CACACGCGCGCTATATT', group_id: 'bc1017_BAK8B_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'TCACGTGCTCACTGTGT', group_id: 'bc1018_BAK8B_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'ACACACTCTATCAGATT', group_id: 'bc1019_BAK8B_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'CACGACACGACGATGTT', group_id: 'bc1020_BAK8B_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'CTATACATAGTGATGTT', group_id: 'bc1021_BAK8B_OA', set_name: 'pacbio')
    Tag.create!(oligo: 'CACTCACGTGTGATATT', group_id: 'bc1022_BAK8B_OA', set_name: 'pacbio')
    puts '-> Tags successfully created'
  end

  task destroy: :environment do
    Tag.delete_all
    puts '-> Tags successfully deleted'
  end
end
