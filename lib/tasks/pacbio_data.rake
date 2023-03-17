# frozen_string_literal: true

require 'securerandom'

namespace :pacbio_data do
  desc 'Populate the database with pacbio plates and runs'
  task create: [:environment, 'tags:create:pacbio_sequel', 'tags:create:pacbio_isoseq'] do
    unless Object.const_defined?('FactoryBot')
      require 'factory_bot'
      FactoryBot.factories.clear
      FactoryBot.find_definitions
    end

    puts '-> Creating pacbio plates...'
    external_plates = FactoryBot.build_list(:external_plate, 5)
    external_plates.each { |plate| Pacbio::PlateCreator.new({ plates: [plate] }).save! }
    puts '-> Pacbio plates successfully created'

    puts '-> Creating pacbio libraries...'

    pools = [
      { library_type: 'Sequel-v1', tag_set: nil, size: 1 },
      { library_type: 'Sequel-v1', tag_set: 'Sequel_16_barcodes_v3', size: 1 },
      { library_type: 'Sequel-v1', tag_set: 'Sequel_16_barcodes_v3', size: 5 },
      { library_type: 'IsoSeq-v1', tag_set: 'IsoSeq_Primers_12_Barcodes_v1', size: 1 },
      { library_type: 'IsoSeq-v1', tag_set: 'IsoSeq_Primers_12_Barcodes_v1', size: 5 },
      { library_type: 'IsoSeq-v1', tag_set: 'IsoSeq_Primers_12_Barcodes_v1', size: 5 }
    ]

    external_study_id = SecureRandom.uuid

    pool_records = pools.map.with_index do |data, pool_index|
      attributes = Array.new(data[:size]) do |library_index|
        unique_index = (1000 * pool_index) + library_index
        {
          request: {
            library_type: data[:library_type],
            estimate_of_gb_required: 10,
            number_of_smrt_cells: 3,
            cost_code: 'PSD1234',
            external_study_id:
          },
          sample: {
            name: "PacbioSample#{unique_index}",
            external_id: SecureRandom.uuid,
            species: "Species#{unique_index}"
          }
        }
      end
      factory = Pacbio::RequestFactory.new(attributes).tap(&:save)
      tube = Tube.create
      tags = data[:tag_set] ? TagSet.find_by!(name: data[:tag_set]).tags : []

      factory.requests.each_with_index.reduce(nil) do |pool, (request, tag_index)|
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
      run = Pacbio::Run.create!(name: "Run#{pool.id}", sequencing_kit_box_barcode: "SKB#{pool.id}", dna_control_complex_box_barcode: "DCCB#{pool.id}")
      plate = Pacbio::Plate.create(run:)
      Pacbio::Well.create!(plate:, pools: [pool], movie_time: 20, on_plate_loading_concentration: 1, row: 'A', column: i + 1, generate_hifi: 'In SMRT Link', ccs_analysis_output: 'Yes', binding_kit_box_barcode: "BKB#{pool.id}")
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
