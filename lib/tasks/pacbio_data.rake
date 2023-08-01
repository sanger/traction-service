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

    requests = reception_generator.reception.requests.each

    print COMPLETED

    print '-> Creating pacbio libraries...'

    # TODO: refactor the pools array below to better correspond to requests, libraries, and pools
    pools = [
      { library_type: 'Pacbio_HiFi', tag_set: nil, size: 1 },
      { library_type: 'Pacbio_HiFi', tag_set: 'Sequel_16_barcodes_v3', size: 1 },
      { library_type: 'Pacbio_HiFi_mplx', tag_set: 'Sequel_16_barcodes_v3', size: 5 },
      { library_type: 'PacBio_IsoSeq_mplx', tag_set: 'IsoSeq_Primers_12_Barcodes_v1', size: 1 },
      { library_type: 'Pacbio_IsoSeq', tag_set: 'IsoSeq_Primers_12_Barcodes_v1', size: 5 }
    ]

    pool_records = pools.map do |data|
      tube = Tube.create
      tags = data[:tag_set] ? TagSet.find_by!(name: data[:tag_set]).tags : []

      requests.take(data[:size]).each_with_index.reduce(nil) do |pool, (request, tag_index)|
        Pacbio::Library.create!(
          volume: 1,
          concentration: 1,
          template_prep_kit_box_barcode: 'LK12345',
          insert_size: 100,
          request: request.requestable,
          tag: tags[tag_index]
        ) do |lib|
          lib.pool = pool ||
                     Pacbio::Pool.new(tube:,
                                      volume: lib.volume,
                                      concentration: lib.concentration,
                                      template_prep_kit_box_barcode: lib.template_prep_kit_box_barcode,
                                      insert_size: lib.insert_size,
                                      libraries: [lib])
        end.pool
      end
    end
    print COMPLETED

    print '-> Finding Pacbio SMRT Link versions...'
    v11 = Pacbio::SmrtLinkVersion.find_by(name: 'v11')
    v12_revio = Pacbio::SmrtLinkVersion.find_by(name: 'v12_revio')
    v12_sequel_iie = Pacbio::SmrtLinkVersion.find_by(name: 'v12_sequel_iie')
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

    print "   -> Creating runs for #{v11.name}..."
    pool_records.each_with_index do |pool, i|
      Pacbio::Run.create!(
        name: "Run11#{pool.id}",
        system_name: Pacbio::Run.system_names['Sequel IIe'],
        smrt_link_version: v11,
        dna_control_complex_box_barcode: "DCCB#{pool.id}",
        plates: [Pacbio::Plate.new(
          sequencing_kit_box_barcode: "SKB#{pool.id}",
          plate_number: 1,
          wells: [Pacbio::Well.new(
            pools: [pool],
            row: 'A',
            column: i + 1,
            ccs_analysis_output_include_kinetics_information:	'Yes',
            ccs_analysis_output_include_low_quality_reads:	'Yes',
            include_fivemc_calls_in_cpg_motifs:	'Yes',
            demultiplex_barcodes:	'In SMRT Link',
            on_plate_loading_concentration: 1,
            binding_kit_box_barcode: "BKB#{pool.id}",
            movie_time: '20.0'
          )]
        )]
      )
    end
    print COMPLETED

    print "   -> Creating runs for #{v12_revio.name}..."
    pool_records.each_with_index do |pool, i|
      plate1 = Pacbio::Plate.new(
        sequencing_kit_box_barcode: "SKB#{pool.id}1",
        plate_number: 1,
        wells: [Pacbio::Well.new(
          pools: [pool],
          row: 'A',
          column: 1,
          pre_extension_time: 2,
          movie_acquisition_time:	'24.0',
          include_base_kinetics:	'True',
          library_concentration:	1,
          polymerase_kit:	"PK12#{i}"
        )]
      )
      plate2 = Pacbio::Plate.new(
        sequencing_kit_box_barcode: "SKB#{pool.id}2",
        plate_number: 2,
        wells: [Pacbio::Well.new(
          pools: [pool],
          row: 'A',
          column: 1,
          pre_extension_time: 2,
          movie_acquisition_time:	'24.0',
          include_base_kinetics:	'True',
          library_concentration:	1,
          polymerase_kit:	"PK12#{i}"
        ), Pacbio::Well.new(
          pools: [pool],
          row: 'B',
          column: 1,
          pre_extension_time: 2,
          movie_acquisition_time:	'24.0',
          include_base_kinetics:	'True',
          library_concentration:	1,
          polymerase_kit:	"PK12#{i}"
        )]
      )
      Pacbio::Run.create!(
        system_name: Pacbio::Run.system_names['Revio'],
        smrt_link_version: v12_revio,
        dna_control_complex_box_barcode: "DCCB#{pool.id}",
        plates: [plate1] + (i > 2 ? [plate2] : [])
      )
    end
    print COMPLETED

    print "   -> Creating runs for #{v12_sequel_iie.name}..."
    pool_records.zip(pools).each_with_index do |(pool, tag_set), i|
      Pacbio::Run.create!(
        name: "RUN-#{v12_sequel_iie.name}-#{tag_set[:tag_set]}x#{tag_set[:size]}",
        system_name: Pacbio::Run.system_names['Sequel IIe'],
        smrt_link_version: v12_sequel_iie,
        plates: [Pacbio::Plate.new(
          sequencing_kit_box_barcode: "SKB#{pool.id}",
          plate_number: 1,
          wells: [Pacbio::Well.new(
            pools: [pool],
            row: 'A',
            column: i + 1,
            ccs_analysis_output_include_kinetics_information:	'Yes',
            ccs_analysis_output_include_low_quality_reads:	'Yes',
            include_fivemc_calls_in_cpg_motifs:	'Yes',
            demultiplex_barcodes:	'In SMRT Link',
            on_plate_loading_concentration: 1,
            binding_kit_box_barcode: "BKB#{pool.id}",
            movie_time: '20.0'
          )]
        )]
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
