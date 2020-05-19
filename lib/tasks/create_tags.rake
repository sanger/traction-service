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
    puts '-> Creating ONT tag set for 96 sample wells'
    constants_accessor = Pipelines::ConstantsAccessor.new(Pipelines.ont.covid)
    tag_set = TagSet.create!(name: constants_accessor.pcr_tag_set_name, uuid: SecureRandom.uuid)
    puts '-> Tag Set successfully created'
    oligo = +'ACGTACGTACGTACGT'
    (1..96).each do |tag_index|
      padded_tag_number = format('%<tag_number>02i', { tag_number: tag_index })
      Tag.create!(oligo: oligo,
                  group_id: "ont_96_tag_#{padded_tag_number}",
                  tag_set_id: tag_set.id)
      oligo.increment_oligo!
    end
    puts '-> ONT tag set for 96 sample wells successfully created'
  end

  desc 'Fetch tags and tag sets from sequencescape. Used to seed ONT Covid tags'
  task fetch: :environment do
    constants_accessor = Pipelines::ConstantsAccessor.new(Pipelines.ont.covid)
    tag_group_name = constants_accessor.pcr_tag_set_name
    puts "-> Fetching tag set '#{tag_group_name}' from sequencescape"
    # TODO - use correct hostname for different environments
    uri = URI("http://localhost:3000/api/v2/tag_groups?filter[name]=#{tag_group_name}")
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      res_hash = eval(res.body)
      tag_groups = res_hash[:data]
      show_errors ["-> Expected one and only one tag group"] if tag_groups.count != 1
      tag_group = tag_groups.first
      show_errors ["-> Expected tag group with name '#{tag_group_name}'"] if tag_group[:attributes][:name] != tag_group_name
      tag_set = TagSet.create!(name: tag_group_name, uuid: SecureRandom.uuid)
      puts "-> #{tag_group_name} successfully created"
      tag_group[:attributes][:tags].each_with_index do |tag, idx|
        padded_tag_number = format('%<tag_number>02i', { tag_number: idx + 1 })
        Tag.create!(oligo: tag[:oligo],
                    group_id: "#{tag_group_name}-#{padded_tag_number}",
                    tag_set_id: tag_set.id)
      end
      puts "-> #{tag_group_name} tags successfully created"
    end
  end

  task destroy: :environment do
    Tag.destroy_all
    puts '-> Tags successfully deleted'
    TagSet.destroy_all
    puts '-> Tag Sets successfully deleted'
  end
end
