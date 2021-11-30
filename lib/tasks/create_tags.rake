# frozen_string_literal: true

require 'securerandom'

namespace :tags do
  desc 'Create tags and tag sets'
  namespace :create do
    desc 'Create pacbio sequel tags'
    task pacbio_sequel: :environment do
      puts '-> Creating Sequel_16_barcodes_v3 tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'Sequel_16_barcodes_v3', uuid: '4d87a8ab-4d16-f0b0-77e5-0f467dba442e')
      puts '-> Tag Set successfully created'
      [
        { oligo: 'CACATATCAGAGTGCGT', group_id: 'bc1001_BAK8A_OA' },
        { oligo: 'ACACACAGACTGTGAGT', group_id: 'bc1002_BAK8A_OA' },
        { oligo: 'ACACATCTCGTGAGAGT', group_id: 'bc1003_BAK8A_OA' },
        { oligo: 'ACAGTCGAGCGCTGCGT', group_id: 'bc1008_BAK8A_OA' },
        { oligo: 'ACACACGCGAGACAGAT', group_id: 'bc1009_BAK8A_OA' },
        { oligo: 'ACGCGCTATCTCAGAGT', group_id: 'bc1010_BAK8A_OA' },
        { oligo: 'CTATACGTATATCTATT', group_id: 'bc1011_BAK8A_OA' },
        { oligo: 'ACACTAGATCGCGTGTT', group_id: 'bc1012_BAK8A_OA' },
        { oligo: 'CGCATGACACGTGTGTT', group_id: 'bc1015_BAK8B_OA' },
        { oligo: 'CATAGAGAGATAGTATT', group_id: 'bc1016_BAK8B_OA' },
        { oligo: 'CACACGCGCGCTATATT', group_id: 'bc1017_BAK8B_OA' },
        { oligo: 'TCACGTGCTCACTGTGT', group_id: 'bc1018_BAK8B_OA' },
        { oligo: 'ACACACTCTATCAGATT', group_id: 'bc1019_BAK8B_OA' },
        { oligo: 'CACGACACGACGATGTT', group_id: 'bc1020_BAK8B_OA' },
        { oligo: 'CTATACATAGTGATGTT', group_id: 'bc1021_BAK8B_OA' },
        { oligo: 'CACTCACGTGTGATATT', group_id: 'bc1022_BAK8B_OA' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> Sequel_16_barcodes_v3 tags successfully created'
    end

    desc 'Create pacbio IsoSeq tags'
    task pacbio_isoseq: :environment do
      puts '-> Creating Pacbio IsoSeq tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'IsoSeq_Primers_12_Barcodes_v1', uuid: 'd1bb7419-4343-286f-f6f7-7365fa2d1ee9')
      puts '-> Tag Set successfully created'
      [
        { oligo: 'CACATATCAGAGTGCG', group_id: 'bc1001' },
        { oligo: 'ACACACAGACTGTGAG', group_id: 'bc1002' },
        { oligo: 'ACACATCTCGTGAGAG', group_id: 'bc1003' },
        { oligo: 'CACGCACACACGCGCG', group_id: 'bc1004' },
        { oligo: 'CACTCGACTCTCGCGT', group_id: 'bc1005' },
        { oligo: 'CATATATATCAGCTGT', group_id: 'bc1006' },
        { oligo: 'ACAGTCGAGCGCTGCG', group_id: 'bc1008' },
        { oligo: 'ACACTAGATCGCGTGT', group_id: 'bc1012' },
        { oligo: 'TCACGTGCTCACTGTG', group_id: 'bc1018' },
        { oligo: 'ACACACTCTATCAGAT', group_id: 'bc1019' },
        { oligo: 'CACGACACGACGATGT', group_id: 'bc1020' },
        { oligo: 'CAGAGAGATATCTCTG', group_id: 'bc1023' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> IsoSeq_Primers_12_Barcodes_v1 created'
    end

    desc 'Create ont tags for 96 samples (dummy not prod)'
    task ont_96: :environment do
      puts '-> Creating ONT tag set for 96 sample wells'
      tag_set_name = Pipelines::ConstantsAccessor.ont_covid_pcr_tag_set_name
      tag_set = TagSet.ont_pipeline
                      .find_or_create_by!(name: tag_set_name, uuid: SecureRandom.uuid)
      puts '-> Tag Set successfully created'
      (1..96).each do |tag_index|
        # Generate incremental 24 character long oligos for development
        oligo = (78901234567890 + tag_index).to_s(4).tr('0', 'A').tr('1', 'T').tr('2', 'C').tr('3', 'G')
        padded_tag_number = format('%<tag_number>02i', { tag_number: tag_index })
        Tag.find_or_create_by!(oligo: oligo,
                               group_id: "ont_96_tag_#{padded_tag_number}",
                               tag_set_id: tag_set.id)
      end
      puts '-> ONT tag set for 96 sample wells successfully created'
    end
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
      tag_set = TagSet.ont_pipeline
                      .find_or_create_by!(name: tag_group_name, uuid: SecureRandom.uuid)
      puts "-> #{tag_group_name} successfully created"
      tag_group['attributes']['tags'].each_with_index do |tag, idx|
        padded_tag_number = format('%<tag_number>02i', { tag_number: idx + 1 })
        Tag.find_or_create_by!(oligo: tag['oligo'],
                               group_id: "#{tag_group_name}-#{padded_tag_number}",
                               tag_set_id: tag_set.id)
      end
      puts "-> #{tag_group_name} tags successfully created"
    end
  end

  # to run this use bundle exec rake BARCODES=barcode1,barcode2 tags:reorder
  desc 'reorder ONT tags by column rather than row.'
  task reorder: :environment do
    tag_set = TagSet.find_by(name: Pipelines::ConstantsAccessor.ont_covid_pcr_tag_set_name)
    ENV['BARCODES'].split(',').each do |barcode|
      puts "Reordering tags for plate #{barcode}"
      plate = Plate.find_by(barcode: barcode)
      Ont::AddTags.run!(plate: plate, tag_set: tag_set, order: 'column')
      library = Ont::Library.where("name like '%#{plate.barcode}%'").first
      Messages.publish(library.flowcell.run, Pipelines.ont.message)
    end
  rescue StandardError => e
    puts e
    puts 'Something went wrong. It was probably your fault!'
  end

  task destroy: :environment do
    Tag.destroy_all
    puts '-> Tags successfully deleted'
    TagSet.destroy_all
    puts '-> Tag Sets successfully deleted'
  end
end
