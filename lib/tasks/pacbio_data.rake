# frozen_string_literal: true

require 'securerandom'

namespace :pacbio_data do
  desc 'Populate the database with pacbio plates and runs'
  task create: [:environment, 'tags:create:pacbio_sequel', 'tags:create:pacbio_isoseq'] do
    require_relative 'reception_generator'

    puts '-> Creating pacbio plates and tubes...'

    reception_generator = ReceptionGenerator.new(
      number_of_plates: 5,
      number_of_tubes: 5,
      wells_per_plate: 48,
      pipeline: :pacbio
    ).tap(&:construct_resources!)

    requests = reception_generator.reception.requests.each

    puts '-> Pacbio plates successfully created'

    puts '-> Creating pacbio libraries...'

    pools = [
      { library_type: 'Pacbio_HiFi', tag_set: nil, size: 1 },
      { library_type: 'Pacbio_HiFi', tag_set: 'Sequel_16_barcodes_v3', size: 1 },
      { library_type: 'Pacbio_HiFi_mplx', tag_set: 'Sequel_16_barcodes_v3', size: 5 },
      { library_type: 'PacBio_IsoSeq_mplx', tag_set: 'IsoSeq_Primers_12_Barcodes_v1', size: 1 },
      { library_type: 'Pacbio_IsoSeq', tag_set: 'IsoSeq_Primers_12_Barcodes_v1', size: 5 },
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
    puts '-> Pacbio libraries successfully created'

    puts '-> Creating pacbio runs...'
    pool_records.each_with_index do |pool, i|
      Pacbio::Run.create!(
        name: "Run#{pool.id}",
        dna_control_complex_box_barcode: "DCCB#{pool.id}",
        plates: [Pacbio::Plate.new(
          sequencing_kit_box_barcode: "SKB#{pool.id}",
          plate_number: 1,
          wells: [Pacbio::Well.new(
            pools: [pool],
            row: 'A',
            column: i + 1,
            ccs_analysis_output: 'Yes',
            generate_hifi: 'In SMRT Link',
            on_plate_loading_concentration: 1,
            binding_kit_box_barcode: "BKB#{pool.id}",
            movie_time: 20
          )]
        )]
      )
    end
    puts '-> Pacbio runs successfully created'
  end

  task destroy: :environment do
    Sample.all.each do |sample|
      sample.destroy if sample.requests[0].requestable_type == 'Pacbio::Request'
    end
    [Pacbio::Request, Pacbio::Library, Pacbio::Run, Pacbio::Plate, Pacbio::Well,
     Pacbio::WellPool, Pacbio::Pool].each(&:delete_all)
    Plate.by_pipeline('Pacbio').destroy_all

    puts '-> Pacbio data successfully deleted'
  end
end
