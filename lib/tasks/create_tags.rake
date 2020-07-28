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
    tag_set_name = Pipelines::ConstantsAccessor.ont_covid_pcr_tag_set_name
    tag_set = TagSet.create!(name: tag_set_name, uuid: SecureRandom.uuid)
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
    tag_group_name = Pipelines::ConstantsAccessor.ont_covid_pcr_tag_set_name
    tag_group_hostname = Pipelines::ConstantsAccessor.ont_covid_pcr_tag_set_hostname
    puts "-> Fetching tag set '#{tag_group_name}' from sequencescape"
    uri = URI("http://#{tag_group_hostname}/api/v2/tag_groups?filter[name]=#{tag_group_name}")
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      json_res = JSON.parse(res.body)
      tag_groups = json_res['data']
      show_errors ['-> Expected one and only one tag group'] if tag_groups.count != 1
      tag_group = tag_groups.first
      if tag_group['attributes']['name'] != tag_group_name
        show_errors ["-> Expected tag group with name '#{tag_group_name}'"]
      end
      tag_set = TagSet.create!(name: tag_group_name, uuid: SecureRandom.uuid)
      puts "-> #{tag_group_name} successfully created"
      tag_group['attributes']['tags'].each_with_index do |tag, idx|
        padded_tag_number = format('%<tag_number>02i', { tag_number: idx + 1 })
        Tag.create!(oligo: tag['oligo'],
                    group_id: "#{tag_group_name}-#{padded_tag_number}",
                    tag_set_id: tag_set.id)
      end
      puts "-> #{tag_group_name} tags successfully created"
    end
  end

  desc 'reorder ONT tags by column rather than row.'
  task :reorder_tags, [:barcodes] => :environment do |_t, args|
    tags = TagSet.find_by(name: 'ONT_EXP-PBC096').tags.order(:group_id)
    plate_map = {1=>"A1", 2=>"B1", 3=>"C1", 4=>"D1", 5=>"E1", 6=>"F1", 7=>"G1", 8=>"H1", 9=>"A2", 10=>"B2", 11=>"C2", 12=>"D2", 13=>"E2", 14=>"F2", 15=>"G2", 16=>"H2", 17=>"A3", 18=>"B3", 19=>"C3", 20=>"D3", 21=>"E3", 22=>"F3", 23=>"G3", 24=>"H3", 25=>"A4", 26=>"B4", 27=>"C4", 28=>"D4", 29=>"E4", 30=>"F4", 31=>"G4", 32=>"H4", 33=>"A5", 34=>"B5", 35=>"C5", 36=>"D5", 37=>"E5", 38=>"F5", 39=>"G5", 40=>"H5", 41=>"A6", 42=>"B6", 43=>"C6", 44=>"D6", 45=>"E6", 46=>"F6", 47=>"G6", 48=>"H6", 49=>"A7", 50=>"B7", 51=>"C7", 52=>"D7", 53=>"E7", 54=>"F7", 55=>"G7", 56=>"H7", 57=>"A8", 58=>"B8", 59=>"C8", 60=>"D8", 61=>"E8", 62=>"F8", 63=>"G8", 64=>"H8", 65=>"A9", 66=>"B9", 67=>"C9", 68=>"D9", 69=>"E9", 70=>"F9", 71=>"G9", 72=>"H9", 73=>"A10", 74=>"B10", 75=>"C10", 76=>"D10", 77=>"E10", 78=>"F10", 79=>"G10", 80=>"H10", 81=>"A11", 82=>"B11", 83=>"C11", 84=>"D11", 85=>"E11", 86=>"F11", 87=>"G11", 88=>"H11", 89=>"A12", 90=>"B12", 91=>"C12", 92=>"D12", 93=>"E12", 94=>"F12", 95=>"G12", 96=>"H12"}
    args[:barcodes].split(',').each do |barcode|
      tags.each_with_index do |tag, index|
        plate = Plate.find_by(barcode: barcode)
        well = plate.wells.find_by(position: plate_map[index+1])
        next if well.nil?
        next if well.container_materials.empty?
        material = well.container_materials.first.material
        material_tag = material.tags.first
        material_tag = tag
        puts material_tag.oligo
        puts tag.oligo
        material_tag.save!
      end 
    end
  end

  task destroy: :environment do
    Tag.destroy_all
    puts '-> Tags successfully deleted'
    TagSet.destroy_all
    puts '-> Tag Sets successfully deleted'
  end
end
