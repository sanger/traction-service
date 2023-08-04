# frozen_string_literal: true

require 'securerandom'

BACKSPACE = "\b"
SUCCESS = '√'
NEWLINE = "\n"
# COMPLETED replaces '...' on the previous line with a success symbol, used with print, not puts
COMPLETED = (BACKSPACE * 3) + " #{SUCCESS} " + NEWLINE

namespace :pacbio_data do
  desc 'Populate the database with pacbio plates and runs'
  task create: [:environment, 'tags:create:pacbio_sequel', 'tags:create:pacbio_isoseq'] do
    require_relative 'reception_generator'

    print '-> Creating pacbio plates and tubes...'

    @reception_generator = ReceptionGenerator.new(
      number_of_plates: 5,
      number_of_tubes: 5,
      wells_per_plate: 48,
      pipeline: :pacbio
    ).tap(&:construct_resources!)

    print COMPLETED

    print '-> Creating pacbio libraries...'

    # Generate a psuedo-unique barcode
    # default => 12345678
    # length: 4 => 1234
    # bits: 36 => uur0cj2h
    # Inspired by http://web.archive.org/web/20120925034700/http://blog.logeek.fr/2009/7/2/creating-small-unique-tokens-in-ruby
    def barcode(length: 8, bits: 10)
      rand(bits**length).to_s(bits).rjust(length, '0')
    end

    def library(tag_name)
      contents = {
        volume: 1,
        concentration: 1,
        template_prep_kit_box_barcode: 'LK12345',
        insert_size: 100
      }
      request = @reception_generator.reception.requests.first.requestable
      tag = TagSet.find_by!(name: tag_name).tags.first if tag_name
      Pacbio::Library.create!(request:, tag:, **contents) do |lib|
        lib.pool = Pacbio::Pool.new(tube: Tube.create, libraries: [lib], **contents)
      end.pool
    end

    # pools
    untagged_pool = library nil
    tagged_pool = library 'Sequel_16_barcodes_v3'

    print COMPLETED

    print '-> Finding Pacbio SMRT Link versions...'
    v11 = Pacbio::SmrtLinkVersion.find_by(name: 'v11')
    v12_revio = Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio')
    print COMPLETED

    puts '-> Creating pacbio runs:'

    # See required structure in 'config/pacbio_smrt_link_versions.yml'
    # Or execute the DB query below:
    #
    # SELECT
    #   versions.name,
    #   options_.key,
    #   options_.default_value
    # FROM
    #   pacbio_smrt_link_option_versions AS option_versions
    #   JOIN pacbio_smrt_link_versions AS versions
    #     ON option_versions.pacbio_smrt_link_version_id = versions.id
    #   JOIN pacbio_smrt_link_options AS options_
    #     ON option_versions.pacbio_smrt_link_option_id = options_.id
    # ORDER BY
    #     option_versions.id

    # TODO: create the seed data below with the appropiate options dynamically sourced from config

    # combinations
    total_plates = { sequel_iie: [1], revio: [1, 2] }
    pools = {
      sequel_iie: { untagged: untagged_pool, tagged: tagged_pool },
      revio: { untagged: untagged_pool, tagged: tagged_pool }
    }

    print "   -> Creating runs for #{v11.name}..."
    total_plates[:sequel_iie].product(pools[:sequel_iie].to_a).each do |total_plate, (pool_name, pool)|
      Pacbio::Run.create!(
        name: "RUN-#{v11.name}-#{pool_name}-#{total_plate}_plate",
        system_name: Pacbio::Run.system_names['Sequel IIe'],
        smrt_link_version: v11,
        dna_control_complex_box_barcode: "DCCB_#{barcode}",
        plates: (1..total_plate).map do |plate_number|
          Pacbio::Plate.new(
            sequencing_kit_box_barcode: "SKB_#{barcode(length: 21 - 4)}",
            plate_number:,
            wells: [Pacbio::Well.new(
              pools: [pool],
              row: 'A',
              column: 1,
              ccs_analysis_output_include_kinetics_information:	'Yes',
              ccs_analysis_output_include_low_quality_reads:	'Yes',
              include_fivemc_calls_in_cpg_motifs:	'Yes',
              demultiplex_barcodes:	'In SMRT Link',
              generate_hifi: 'In SMRT Link',
              on_plate_loading_concentration: 1,
              binding_kit_box_barcode: "BKB_#{barcode}",
              movie_time: '20.0'
            )]
          )
        end
      )
    end
    print COMPLETED

    print "   -> Creating runs for #{v12_revio.name}..."
    total_plates[:revio].product(pools[:revio].to_a).each do |total_plate, (pool_name, pool)|
      Pacbio::Run.create!(
        name: "RUN-#{v12_revio.name}-#{pool_name}-#{total_plate}_plate",
        system_name: Pacbio::Run.system_names['Revio'],
        smrt_link_version: v12_revio,
        dna_control_complex_box_barcode: "DCCB_#{barcode}",
        plates: (1..total_plate).map do |plate_number|
          serial = barcode(length: 3)
          sequencing_kit_box_barcode = "10211880003110400#{serial}20231226"
          Pacbio::Plate.new(
            sequencing_kit_box_barcode:,
            plate_number:,
            wells: [Pacbio::Well.new(
              pools: [pool],
              row: 'A',
              column: 1,
              pre_extension_time: 2,
              movie_acquisition_time:	'24.0',
              include_base_kinetics: 'True',
              library_concentration: 1,
              polymerase_kit:	'030116102739100011124'
            )]
          )
        end
      )
    end
    print COMPLETED

    puts '-> Pacbio runs successfully created'
  end

  task destroy: :environment do
    Sample.all.each do |sample|
      sample.destroy if sample.requests[0].requestable_type == 'Pacbio::Request'
    end
    [Pacbio::Request, Pacbio::Library, Pacbio::Run, Pacbio::Plate, Pacbio::Well,
     Pacbio::WellPool, Pacbio::Pool].each(&:delete_all)
    Plate.by_pipeline('Pacbio').destroy_all

    print '-> Pacbio data successfully deleted'
  end
end
