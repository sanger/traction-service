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

    reception_generator = ReceptionGenerator.new(
      number_of_plates: 5,
      number_of_tubes: 5,
      wells_per_plate: 48,
      pipeline: :pacbio
    ).tap(&:construct_resources!)
    @requests_generator = reception_generator.reception.requests.cycle # set as instance variable to be used in library creation

    print COMPLETED

    print '-> Creating pacbio libraries and pools...'

    def library(tag_id = nil)
      Pacbio::Library.new(
        volume: 1,
        concentration: 1,
        template_prep_kit_box_barcode: '029979102141700063023',
        insert_size: 500,
        tag_id:,
        pacbio_request_id: @requests_generator.next.requestable.id,
        primary_aliquot: Aliquot.new(volume: 1,
                                     concentration: 1,
                                     template_prep_kit_box_barcode: '029979102141700063023',
                                     insert_size: 500, tag_id:)
      )
    end

    def pool(tag_name, lib_count = 1)
      tags = TagSet.find_by!(name: tag_name).tags.cycle if tag_name
      libraries = (1..lib_count).collect do
        library(tag_name ? tags.next.id : nil)
      end
      # Created a used_aliquot for each library so the data is consistent
      used_aliquots = libraries.collect do |library|
        Aliquot.new(
          volume: library.volume, concentration: library.concentration, template_prep_kit_box_barcode: library.template_prep_kit_box_barcode,
          insert_size: library.insert_size, tag_id: library.tag_id, source_id: library.pacbio_request_id, source_type: 'Pacbio::Request', aliquot_type: :derived
        )
      end
      Pacbio::Pool.create!(tube: Tube.create, used_aliquots:, volume: 1, concentration: 1, insert_size: 600, template_prep_kit_box_barcode: '029979102141700063023',
                           primary_aliquot: Aliquot.new(volume: 1, concentration: 1, template_prep_kit_box_barcode: '029979102141700063023', insert_size: 500))
    end

    # pools
    def untagged_pool
      pool(nil)
    end

    def tagged_pool
      pool('Sequel_16_barcodes_v3', 4)
    end

    # Create 10 pools with libraries that have no runs
    5.times do
      untagged_pool
      tagged_pool
      library.save!
    end

    print COMPLETED

    print '-> Finding Pacbio SMRT Link versions...'
    v11 = Pacbio::SmrtLinkVersion.find_by!(name: 'v11')
    v12_revio = Pacbio::SmrtLinkVersion.find_by!(name: 'v12_revio')
    v12_sequel_iie = Pacbio::SmrtLinkVersion.find_by!(name: 'v12_sequel_iie')
    v13_revio = Pacbio::SmrtLinkVersion.find_by!(name: 'v13_revio')
    v13_revio.update(default: true, active: true)
    v13_sequel_iie = Pacbio::SmrtLinkVersion.find_by!(name: 'v13_sequel_iie')
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

    # Generate a psuedo-unique barcode
    # default => 12345678
    # length: 4 => 1234
    # bits: 36 => uur0cj2h
    # Inspired by http://web.archive.org/web/20120925034700/http://blog.logeek.fr/2009/7/2/creating-small-unique-tokens-in-ruby
    def barcode(length: 8, bits: 10)
      rand(bits**length).to_s(bits).rjust(length, '0')
    end

    # Gets a random date in the next year
    # This is mainly use when generating valid sequencing kit box barcodes to ensure uniqueness
    # See https://www.pacb.com/wp-content/uploads/SMRT-Link-User-Guide-v13.0.pdf pg 42
    def random_expiration_date
      (DateTime.now + (rand * 365)).strftime('%Y%m%d')
    end

    # combinations
    total_plates = { sequel_iie: [1], revio: [1, 2] }
    pools = {
      sequel_iie: [[:untagged, untagged_pool], [:tagged, tagged_pool]],
      revio: [[:untagged, untagged_pool], [:tagged, tagged_pool]]
    }

    print "   -> Creating runs for #{v11.name}..."
    total_plates[:sequel_iie].product(pools[:sequel_iie]).each do |total_plate, (pool_name, pool)|
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
              row: 'A',
              column: 1,
              on_plate_loading_concentration: 1,
              binding_kit_box_barcode: "BKB_#{barcode}",
              movie_time: '20.0',
              used_aliquots_attributes: [{ source_id: pool.id, source_type: 'Pacbio::Pool', volume: 1.0, concentration: 1.0, template_prep_kit_box_barcode: "TPKB_#{barcode}", insert_size: 500 }],
              **v11.default_options
            )]
          )
        end
      )
    end
    print COMPLETED

    print "   -> Creating runs for #{v12_revio.name}..."
    total_plates[:revio].product(pools[:revio]).each do |total_plate, (pool_name, pool)|
      Pacbio::Run.create!(
        name: "RUN-#{v12_revio.name}-#{pool_name}-#{total_plate}_plate",
        system_name: Pacbio::Run.system_names['Revio'],
        smrt_link_version: v12_revio,
        dna_control_complex_box_barcode: 'Lxxxxx102249600123199',
        plates: (1..total_plate).map do |plate_number|
          serial = barcode(length: 3)
          sequencing_kit_box_barcode = "10211880003110400#{serial}#{random_expiration_date}"
          Pacbio::Plate.new(
            sequencing_kit_box_barcode:,
            plate_number:,
            wells: [Pacbio::Well.new(
              row: 'A',
              column: 1,
              pre_extension_time: 2,
              movie_acquisition_time:	'24.0',
              library_concentration: 1,
              polymerase_kit:	'030116102739100011124',
              used_aliquots_attributes: [{ source_id: pool.id, source_type: 'Pacbio::Pool', volume: 1.0, concentration: 1.0, template_prep_kit_box_barcode: "TPKB_#{barcode}", insert_size: 500 }],
              **v12_revio.default_options
            )]
          )
        end
      )
    end
    print COMPLETED

    print "   -> Creating runs for #{v12_sequel_iie.name}..."
    total_plates[:sequel_iie].product(pools[:sequel_iie]).each do |total_plate, (pool_name, pool)|
      Pacbio::Run.create!(
        name: "RUN-#{v12_sequel_iie.name}-#{pool_name}-#{total_plate}_plate",
        system_name: Pacbio::Run.system_names['Sequel IIe'],
        smrt_link_version: v12_sequel_iie,
        dna_control_complex_box_barcode: 'Lxxxxx102249600123199',
        plates: (1..total_plate).map do |plate_number|
          Pacbio::Plate.new(
            sequencing_kit_box_barcode: '130429101826100021624',
            plate_number:,
            wells: [Pacbio::Well.new(
              row: 'A',
              column: 1,
              pre_extension_time: 2,
              loading_target_p1_plus_p2: 0.85,
              on_plate_loading_concentration: 105,
              binding_kit_box_barcode: '030425102194100010424',
              movie_time: '20.0',
              used_aliquots_attributes: [{ source_id: pool.id, source_type: 'Pacbio::Pool', volume: 1.0, concentration: 1.0, template_prep_kit_box_barcode: "TPKB_#{barcode}", insert_size: 500 }],
              **v12_sequel_iie.default_options
            )]
          )
        end
      )
    end
    print COMPLETED

    print "   -> Creating runs for #{v13_revio.name}..."
    total_plates[:revio].product(pools[:revio]).each do |total_plate, (pool_name, pool)|
      Pacbio::Run.create!(
        name: "RUN-#{v13_revio.name}-#{pool_name}-#{total_plate}_plate",
        system_name: Pacbio::Run.system_names['Revio'],
        smrt_link_version: v13_revio,
        dna_control_complex_box_barcode: 'Lxxxxx102249600123199',
        plates: (1..total_plate).map do |plate_number|
          serial = barcode(length: 3)
          sequencing_kit_box_barcode = "10211880003110400#{serial}#{random_expiration_date}"
          Pacbio::Plate.new(
            sequencing_kit_box_barcode:,
            plate_number:,
            wells: [Pacbio::Well.new(
              row: 'A',
              column: 1,
              pre_extension_time: 2,
              movie_acquisition_time:	'24.0',
              library_concentration: 1,
              polymerase_kit:	'030116102739100011124',
              used_aliquots_attributes: [{ source_id: pool.id, source_type: 'Pacbio::Pool', volume: 1.0, concentration: 1.0, template_prep_kit_box_barcode: "TPKB_#{barcode}", insert_size: 500 }],
              **v13_revio.default_options
            )]
          )
        end
      )
    end
    print COMPLETED

    print "   -> Creating runs for #{v13_sequel_iie.name}..."
    total_plates[:sequel_iie].product(pools[:sequel_iie]).each do |total_plate, (pool_name, pool)|
      Pacbio::Run.create!(
        name: "RUN-#{v13_sequel_iie.name}-#{pool_name}-#{total_plate}_plate",
        system_name: Pacbio::Run.system_names['Sequel IIe'],
        smrt_link_version: v13_sequel_iie,
        dna_control_complex_box_barcode: 'Lxxxxx102249600123199',
        plates: (1..total_plate).map do |plate_number|
          Pacbio::Plate.new(
            sequencing_kit_box_barcode: '130429101826100021624',
            plate_number:,
            # TODO: use defaults
            wells: [Pacbio::Well.new(
              row: 'A',
              column: 1,
              pre_extension_time: 2,
              loading_target_p1_plus_p2: 0.85,
              ccs_analysis_output_include_kinetics_information:	'No',
              ccs_analysis_output_include_low_quality_reads:	'No',
              include_fivemc_calls_in_cpg_motifs:	'No',
              demultiplex_barcodes:	'In SMRT Link',
              on_plate_loading_concentration: 105,
              binding_kit_box_barcode: '030425102194100010424',
              movie_time: '20.0',
              used_aliquots_attributes: [{ source_id: pool.id, source_type: 'Pacbio::Pool', volume: 1.0, concentration: 1.0, template_prep_kit_box_barcode: "TPKB_#{barcode}", insert_size: 500 }]
            )]
          )
        end
      )
    end
    print COMPLETED

    puts '-> Pacbio runs successfully created'
  end

  task destroy: :environment do
    Sample.find_each do |sample|
      sample.destroy if sample.requests[0].requestable_type == 'Pacbio::Request'
    end
    [Pacbio::Request, Pacbio::Library, Pacbio::Run, Pacbio::Plate, Pacbio::Well,
     Pacbio::Pool].each(&:delete_all)
    Plate.by_pipeline('Pacbio').destroy_all

    print '-> Pacbio data successfully deleted'
  end
end
