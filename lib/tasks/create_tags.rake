# frozen_string_literal: true

require 'securerandom'

class String
  def increment_oligo!
    upcase!
    increment_base_at_index!(length - 1)
  end

private

  def increment_base_at_index!(index)
    return unless index >= 0 && index < length

    base_sequence = ['A', 'C', 'G', 'T']
    char_at_index = self[index]
    current_sequence_index = base_sequence.index(char_at_index)
    new_sequence_index = current_sequence_index.nil? ? 0 : current_sequence_index + 1

    if (new_sequence_index == base_sequence.length)
      # We passed the last base in the sequence
      self[index] = base_sequence.first
      increment_base_at_index!(index - 1)
    else
      self[index] = base_sequence[new_sequence_index]
    end
  end
end

namespace :tags do
  task create: :environment do
    puts '-> Creating Sequel_16_barcodes_v3 tag set and tags'
    set = TagSet.create!(name: 'Sequel_16_barcodes_v3', uuid: '4d87a8ab-4d16-f0b0-77e5-0f467dba442e')
    puts '-> Tag Set successfully created'
    Tag.create!(oligo: 'CACATATCAGAGTGCGT', group_id: 'bc1001_BAK8A_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'ACACACAGACTGTGAGT', group_id: 'bc1002_BAK8A_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'ACACATCTCGTGAGAGT', group_id: 'bc1003_BAK8A_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'ACAGTCGAGCGCTGCGT', group_id: 'bc1008_BAK8A_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'ACACACGCGAGACAGAT', group_id: 'bc1009_BAK8A_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'ACGCGCTATCTCAGAGT', group_id: 'bc1010_BAK8A_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'CTATACGTATATCTATT', group_id: 'bc1011_BAK8A_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'ACACTAGATCGCGTGTT', group_id: 'bc1012_BAK8A_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'CGCATGACACGTGTGTT', group_id: 'bc1015_BAK8B_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'CATAGAGAGATAGTATT', group_id: 'bc1016_BAK8B_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'CACACGCGCGCTATATT', group_id: 'bc1017_BAK8B_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'TCACGTGCTCACTGTGT', group_id: 'bc1018_BAK8B_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'ACACACTCTATCAGATT', group_id: 'bc1019_BAK8B_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'CACGACACGACGATGTT', group_id: 'bc1020_BAK8B_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'CTATACATAGTGATGTT', group_id: 'bc1021_BAK8B_OA', tag_set_id: set.id)
    Tag.create!(oligo: 'CACTCACGTGTGATATT', group_id: 'bc1022_BAK8B_OA', tag_set_id: set.id)
    puts '-> Tags successfully created'

    puts '-> Creating 96 dummy tag sets with 96 dummy tags each'
    tag_set_prefix = +'ACGTA'
    96.times do |tag_set_index|
      oligo = +"#{tag_set_prefix}ACGTA"
      tag_set = TagSet.create!(name: ("Dummy_96_barcodes_%02d" % [tag_set_index + 1]),
                               uuid: SecureRandom.uuid)

      96.times do |tag_index|
        Tag.create!(oligo: oligo,
                    group_id: ("dt%02d_%02d" % [tag_set_index + 1, tag_index + 1]),
                    tag_set_id: tag_set.id)
        oligo.increment_oligo!
      end

      puts "-> Created dummy tag set number #{tag_set_index + 1}"
      tag_set_prefix.increment_oligo!
    end

    puts '-> All dummy tag sets successfully created'
  end

  task destroy: :environment do
    Tag.delete_all
    puts '-> Tags successfully deleted'
    TagSet.delete_all
    puts '-> Tag Sets successfully deleted'
  end
end
