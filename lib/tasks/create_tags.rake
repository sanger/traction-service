# frozen_string_literal: true

require 'securerandom'

# Extension methods for String
# to handle incrementing oligo sequences
class String
  def increment_oligo!
    upcase!
    increment_base_at_index!(length - 1)
  end

  private

  def increment_base_at_index!(index)
    return unless index >= 0 && index < length

    base_sequence = %w[A C G T]
    char_at_index = self[index]
    current_sequence_index = base_sequence.index(char_at_index)
    new_sequence_index = current_sequence_index.nil? ? 0 : current_sequence_index + 1

    if new_sequence_index == base_sequence.length
      # We passed the last base in the sequence
      self[index] = base_sequence.first
      increment_base_at_index!(index - 1)
    else
      self[index] = base_sequence[new_sequence_index]
    end
  end
end

namespace :tags do
  desc 'Create tags and tag sets'
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
    puts '-> Sequel_16_barcodes_v3 tags successfully created'

    puts
    tag_set_name = Pipelines::ConstantsAccessor.new(Pipelines.ont.covid).pcr_tag_set_name
    puts "-> Creating #{tag_set_name} tag set and tags"
    tag_set = TagSet.create!(name: tag_set_name, uuid: SecureRandom.uuid)
    Tag.create!(oligo: 'A', group_id: "#{tag_set_name}-01", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'T', group_id: "#{tag_set_name}-02", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'C', group_id: "#{tag_set_name}-03", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'G', group_id: "#{tag_set_name}-04", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TA', group_id: "#{tag_set_name}-05", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TT', group_id: "#{tag_set_name}-06", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TC', group_id: "#{tag_set_name}-07", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TG', group_id: "#{tag_set_name}-08", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CA', group_id: "#{tag_set_name}-09", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CT', group_id: "#{tag_set_name}-10", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CC', group_id: "#{tag_set_name}-11", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CG', group_id: "#{tag_set_name}-12", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GA', group_id: "#{tag_set_name}-13", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GT', group_id: "#{tag_set_name}-14", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GC', group_id: "#{tag_set_name}-15", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GG', group_id: "#{tag_set_name}-16", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAA', group_id: "#{tag_set_name}-17", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAT', group_id: "#{tag_set_name}-18", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAC', group_id: "#{tag_set_name}-19", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAG', group_id: "#{tag_set_name}-20", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTA', group_id: "#{tag_set_name}-21", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTT', group_id: "#{tag_set_name}-22", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTC', group_id: "#{tag_set_name}-23", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTG', group_id: "#{tag_set_name}-24", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TCA', group_id: "#{tag_set_name}-25", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TCT', group_id: "#{tag_set_name}-26", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TCC', group_id: "#{tag_set_name}-27", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TCG', group_id: "#{tag_set_name}-28", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TGA', group_id: "#{tag_set_name}-29", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TGT', group_id: "#{tag_set_name}-30", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TGC', group_id: "#{tag_set_name}-31", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TGG', group_id: "#{tag_set_name}-32", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CAA', group_id: "#{tag_set_name}-33", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CAT', group_id: "#{tag_set_name}-34", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CAC', group_id: "#{tag_set_name}-35", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CAG', group_id: "#{tag_set_name}-36", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CTA', group_id: "#{tag_set_name}-37", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CTT', group_id: "#{tag_set_name}-38", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CTC', group_id: "#{tag_set_name}-39", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CTG', group_id: "#{tag_set_name}-40", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CCA', group_id: "#{tag_set_name}-41", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CCT', group_id: "#{tag_set_name}-42", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CCC', group_id: "#{tag_set_name}-43", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CCG', group_id: "#{tag_set_name}-44", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CGA', group_id: "#{tag_set_name}-45", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CGT', group_id: "#{tag_set_name}-46", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CGC', group_id: "#{tag_set_name}-47", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'CGG', group_id: "#{tag_set_name}-48", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GAA', group_id: "#{tag_set_name}-49", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GAT', group_id: "#{tag_set_name}-50", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GAC', group_id: "#{tag_set_name}-51", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GAG', group_id: "#{tag_set_name}-52", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GTA', group_id: "#{tag_set_name}-53", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GTT', group_id: "#{tag_set_name}-54", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GTC', group_id: "#{tag_set_name}-55", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GTG', group_id: "#{tag_set_name}-56", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GCA', group_id: "#{tag_set_name}-57", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GCT', group_id: "#{tag_set_name}-58", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GCC', group_id: "#{tag_set_name}-59", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GCG', group_id: "#{tag_set_name}-60", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GGA', group_id: "#{tag_set_name}-61", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GGT', group_id: "#{tag_set_name}-62", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GGC', group_id: "#{tag_set_name}-63", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'GGG', group_id: "#{tag_set_name}-64", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAAA', group_id: "#{tag_set_name}-65", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAAT', group_id: "#{tag_set_name}-66", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAAC', group_id: "#{tag_set_name}-67", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAAG', group_id: "#{tag_set_name}-68", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TATA', group_id: "#{tag_set_name}-69", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TATT', group_id: "#{tag_set_name}-70", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TATC', group_id: "#{tag_set_name}-71", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TATG', group_id: "#{tag_set_name}-72", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TACA', group_id: "#{tag_set_name}-73", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TACT', group_id: "#{tag_set_name}-74", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TACC', group_id: "#{tag_set_name}-75", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TACG', group_id: "#{tag_set_name}-76", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAGA', group_id: "#{tag_set_name}-77", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAGT', group_id: "#{tag_set_name}-78", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAGC', group_id: "#{tag_set_name}-79", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TAGG', group_id: "#{tag_set_name}-80", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTAA', group_id: "#{tag_set_name}-81", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTAT', group_id: "#{tag_set_name}-82", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTAC', group_id: "#{tag_set_name}-83", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTAG', group_id: "#{tag_set_name}-84", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTTA', group_id: "#{tag_set_name}-85", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTTT', group_id: "#{tag_set_name}-86", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTTC', group_id: "#{tag_set_name}-87", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTTG', group_id: "#{tag_set_name}-88", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTCA', group_id: "#{tag_set_name}-89", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTCT', group_id: "#{tag_set_name}-90", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTCC', group_id: "#{tag_set_name}-91", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTCG', group_id: "#{tag_set_name}-92", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTGA', group_id: "#{tag_set_name}-93", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTGT', group_id: "#{tag_set_name}-94", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTGC', group_id: "#{tag_set_name}-95", tag_set_id: tag_set.id)
    Tag.create!(oligo: 'TTGG', group_id: "#{tag_set_name}-96", tag_set_id: tag_set.id)
    puts "-> #{tag_set_name} tags successfully created"
  end

  task destroy: :environment do
    Tag.destroy_all
    puts '-> Tags successfully deleted'
    TagSet.destroy_all
    puts '-> Tag Sets successfully deleted'
  end
end
